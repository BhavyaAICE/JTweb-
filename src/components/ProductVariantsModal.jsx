import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { useCart } from '../contexts/CartContext';
import { openSellAuthCheckout } from '../lib/sellauth';
import './ProductVariantsModal.css';

function ProductVariantsModal({ isOpen, onClose, product }) {
  const [variants, setVariants] = useState([]);
  const [loading, setLoading] = useState(false);
  const [addingToCart, setAddingToCart] = useState(null);
  const { addToCart, user } = useCart();

  useEffect(() => {
    if (isOpen && product && product.has_variants) {
      loadVariants();
    }
  }, [isOpen, product]);

  const loadVariants = async () => {
    setLoading(true);
    try {
      const { data, error } = await supabase
        .from('product_variants')
        .select('*')
        .eq('parent_id', product.id)
        .order('sort_order');

      if (error) throw error;
      setVariants(data || []);
    } catch (error) {
      console.error('Error loading variants:', error);
    } finally {
      setLoading(false);
    }
  };

  const getStockIndicator = (stock) => {
    if (stock === 0) return 'out';
    if (stock < 5) return 'low';
    return 'high';
  };

  const getStockText = (stock) => {
    if (stock === 0) return 'Out of Stock';
    if (stock < 5) return `Only ${stock} left`;
    return 'In Stock';
  };

  const handleAddToCart = async (variant) => {
    if (!user) {
      alert('Please log in to add items to cart');
      return;
    }

    if (variant.stock === 0) {
      alert('This product is currently out of stock.');
      return;
    }

    setAddingToCart(variant.id);
    const success = await addToCart(product.id, variant.id, 1);
    setAddingToCart(null);

    if (success) {
      alert(`${variant.name} added to cart!`);
    } else {
      alert('Error adding to cart');
    }
  };

  const handleBuyNow = async (variant) => {
    const shopId = import.meta.env.VITE_SELLAUTH_SHOP_ID;

    if (!shopId || shopId === '0') {
      alert('SellAuth is not configured. Please add your SellAuth Shop ID to the .env file.');
      return;
    }

    if (!variant.sellauth_product_id) {
      alert('This variant does not have a SellAuth product ID configured. Please contact support.');
      return;
    }

    if (variant.stock === 0) {
      alert('This product is currently out of stock.');
      return;
    }

    const variantId = variant.sellauth_variant_id || null;
    await openSellAuthCheckout(shopId, variant.sellauth_product_id, variantId, 1);
  };

  if (!isOpen || !product) return null;

  return (
    <div className="variants-modal active" onClick={onClose}>
      <div className="variants-modal-content" onClick={(e) => e.stopPropagation()}>
        <div className="variants-header">
          <h2>{product.name}</h2>
          <button className="variants-close" onClick={onClose}>
            &times;
          </button>
        </div>

        <div className="variants-list">
          {loading ? (
            <div style={{ gridColumn: '1 / -1', textAlign: 'center', padding: '40px', color: 'rgba(255, 255, 255, 0.5)' }}>
              Loading products...
            </div>
          ) : variants.length > 0 ? (
            variants.map((variant) => (
              <div key={variant.id} className="variant-item">
                <img
                  src={variant.image || product.image}
                  alt={variant.name}
                  className="variant-image"
                  onError={(e) => {
                    e.target.src = 'https://images.unsplash.com/photo-1614294148960-9aa740632a87?w=400&h=300&fit=crop';
                  }}
                />
                <div className="variant-info">
                  <h3 className="variant-name">{variant.name}</h3>
                  <p className="variant-description">{variant.description}</p>
                  <div className="variant-footer">
                    <div>
                      <div className="variant-pricing">
                        <span className="variant-price">${variant.sale_price?.toFixed(2)}</span>
                        {variant.price !== variant.sale_price && (
                          <span className="variant-original-price">${variant.price?.toFixed(2)}</span>
                        )}
                      </div>
                      <div className="variant-stock">
                        <span className={`stock-indicator ${getStockIndicator(variant.stock)}`}></span>
                        <span>{getStockText(variant.stock)}</span>
                      </div>
                    </div>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button
                        className="variant-add-btn"
                        onClick={() => handleAddToCart(variant)}
                        disabled={variant.stock === 0 || addingToCart === variant.id}
                        style={{ flex: 1 }}
                      >
                        {addingToCart === variant.id ? 'Adding...' : (variant.stock === 0 ? 'Sold Out' : 'Add to Cart')}
                      </button>
                      <button
                        className="variant-buy-btn"
                        onClick={() => handleBuyNow(variant)}
                        disabled={variant.stock === 0}
                        style={{ flex: 1 }}
                      >
                        {variant.stock === 0 ? 'Sold Out' : 'Buy Now'}
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))
          ) : (
            <div style={{ gridColumn: '1 / -1', textAlign: 'center', padding: '40px', color: 'rgba(255, 255, 255, 0.5)' }}>
              No variants available
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default ProductVariantsModal;
