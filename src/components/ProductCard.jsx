import { useState } from 'react';
import { useCart } from '../contexts/CartContext';
import { openSellAuthCheckout } from '../lib/sellauth';
import './ProductCard.css';

function ProductCard({ product, onClick, onAddToCart }) {
  const [adding, setAdding] = useState(false);
  const { addToCart, user } = useCart();
  const handleBuyNow = async (e) => {
    e.stopPropagation();

    const shopId = import.meta.env.VITE_SELLAUTH_SHOP_ID;

    if (!shopId || shopId === '0') {
      alert('SellAuth is not configured. Please add your SellAuth Shop ID to the .env file.');
      return;
    }

    if (product.sellauth_product_id) {
      await openSellAuthCheckout(shopId, product.sellauth_product_id, null, 1);
    } else {
      alert('This product does not have a SellAuth product ID configured.');
    }
  };

  const handleAddToCart = async (e) => {
    e.stopPropagation();

    if (!user) {
      alert('Please log in to add items to cart');
      return;
    }

    if (!product.has_variants && product.stock === 0) {
      alert('This product is currently out of stock.');
      return;
    }

    setAdding(true);
    const success = await addToCart(product.id, null, 1);
    setAdding(false);

    if (success) {
      alert(`${product.name} added to cart!`);
    } else {
      alert('Error adding to cart');
    }
  };

  const handleClick = () => {
    if (onClick) {
      onClick(product);
    }
  };

  const isOutOfStock = !product.has_variants && product.stock === 0;

  return (
    <div className="product-card" onClick={handleClick}>
      <img
        src={product.image}
        alt={product.name}
        className="product-image"
        onError={(e) => {
          e.target.src = 'https://images.unsplash.com/photo-1614294148960-9aa740632a87?w=400&h=300&fit=crop';
        }}
      />
      <div className="product-info">
        <span className="product-category">{product.category}</span>
        <h3 className="product-name">{product.name}</h3>
        {product.has_variants ? (
          <p className="product-variants-badge">Multiple Options Available</p>
        ) : (
          <p className="product-stock">In Stock: {product.stock} units</p>
        )}
        <div className="product-pricing">
          <span className="product-price">Starting at ${product.sale_price?.toFixed(2)}</span>
          {product.price !== product.sale_price && (
            <span className="product-original-price">${product.price?.toFixed(2)}</span>
          )}
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <button
            className="product-btn"
            onClick={product.has_variants ? handleClick : handleAddToCart}
            disabled={isOutOfStock || adding}
            style={isOutOfStock ? { opacity: 0.5, cursor: 'not-allowed' } : { flex: 1 }}
          >
            {adding ? 'Adding...' : (isOutOfStock ? 'Out of Stock' : (product.has_variants ? 'View Options' : 'Add to Cart'))}
          </button>
          {!product.has_variants && (
            <button
              className="product-btn-buy"
              onClick={(e) => { e.stopPropagation(); handleBuyNow(e); }}
              disabled={isOutOfStock}
              style={isOutOfStock ? { opacity: 0.5, cursor: 'not-allowed' } : {}}
            >
              {isOutOfStock ? 'Out of Stock' : 'Buy Now'}
            </button>
          )}
        </div>
      </div>
    </div>
  );
}

export default ProductCard;
