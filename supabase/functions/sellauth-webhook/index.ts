import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Client-Info, Apikey",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      status: 200,
      headers: corsHeaders,
    });
  }

  try {
    const webhookSecret = Deno.env.get("SELLAUTH_WEBHOOK_SECRET");
    const signature = req.headers.get("X-Webhook-Signature");

    if (!signature || !webhookSecret) {
      return new Response(
        JSON.stringify({ error: "Missing signature or webhook secret" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const payload = await req.text();

    const encoder = new TextEncoder();
    const key = await crypto.subtle.importKey(
      "raw",
      encoder.encode(webhookSecret),
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign", "verify"]
    );

    const signatureBuffer = await crypto.subtle.sign(
      "HMAC",
      key,
      encoder.encode(payload)
    );

    const calculatedSignature = Array.from(new Uint8Array(signatureBuffer))
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');

    if (calculatedSignature !== signature) {
      return new Response(
        JSON.stringify({ error: "Invalid signature" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const data = JSON.parse(payload);
    const event = data.event;
    const orderData = data.data;

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") || "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || ""
    );

    if (event === "order.completed" || event === "order.paid") {
      const { error: orderError } = await supabase
        .from("orders")
        .insert({
          order_number: orderData.order_id || orderData.id,
          product_id: orderData.product_id,
          customer_email: orderData.customer_email || orderData.email,
          amount: parseFloat(orderData.total || orderData.amount || 0),
          status: "completed",
          sellauth_order_id: orderData.id || orderData.order_id,
          payment_gateway: orderData.payment_method || "sellauth",
        });

      if (orderError) {
        console.error("Error creating order:", orderError);
        return new Response(
          JSON.stringify({ error: "Failed to create order" }),
          { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      if (orderData.product_id) {
        const { data: product } = await supabase
          .from("products")
          .select("stock")
          .eq("id", orderData.product_id)
          .maybeSingle();

        if (product && product.stock > 0) {
          await supabase
            .from("products")
            .update({ stock: product.stock - 1 })
            .eq("id", orderData.product_id);
        }
      }
    }

    return new Response(
      JSON.stringify({ message: "Webhook processed successfully" }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Webhook error:", error);
    return new Response(
      JSON.stringify({ error: error.message || "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});