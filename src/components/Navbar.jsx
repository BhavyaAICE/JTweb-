import { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useCart } from '../contexts/CartContext';
import CartIcon from '../assets/cart-large-2-svgrepo-com.svg';
import './Navbar.css';

function Navbar({ navigateTo, currentPage }) {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);
  const { user, isAdmin, signOut } = useAuth();
  const { getTotalItems } = useCart();

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 50);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const scrollToSection = (sectionId) => {
    if (currentPage !== 'home') {
      navigateTo('home');
      setTimeout(() => {
        const section = document.getElementById(sectionId);
        if (section) {
          section.scrollIntoView({ behavior: 'smooth' });
        }
      }, 100);
    } else {
      const section = document.getElementById(sectionId);
      if (section) {
        section.scrollIntoView({ behavior: 'smooth' });
      }
    }
    setMobileMenuOpen(false);
  };

  const handleSignOut = async () => {
    await signOut();
    navigateTo('home');
    setMobileMenuOpen(false);
  };

  return (
    <nav className={`navbar ${scrolled ? 'scrolled' : ''}`}>
      <div className="nav-container">
        <div className="logo" onClick={() => navigateTo('home')}>
          AuroraServices
        </div>

        <ul className={`nav-links ${mobileMenuOpen ? 'mobile-open' : ''}`}>
          <li>
            <a onClick={() => { navigateTo('home'); setMobileMenuOpen(false); }}>
              Home
            </a>
          </li>
          <li>
            <a onClick={() => { navigateTo('products'); setMobileMenuOpen(false); }}>
              Products
            </a>
          </li>
          <li>
            <a onClick={() => scrollToSection('about')}>About</a>
          </li>
          <li>
            <a onClick={() => scrollToSection('reviews')}>Reviews</a>
          </li>
          <li>
            <a onClick={() => scrollToSection('faq')}>FAQ</a>
          </li>
          <li>
            <button className="nav-btn cart-btn" onClick={() => { navigateTo('cart'); setMobileMenuOpen(false); }}>
              <img src={CartIcon} alt="Cart" className="cart-icon" />
              {getTotalItems() > 0 && <span className="cart-badge">{getTotalItems()}</span>}
            </button>
          </li>
          {user ? (
            <>
              {isAdmin && (
                <li>
                  <button className="nav-btn" onClick={() => { navigateTo('admin'); setMobileMenuOpen(false); }}>
                    Admin Panel
                  </button>
                </li>
              )}
              <li>
                <button className="nav-btn" onClick={handleSignOut} style={{ background: 'transparent', border: '1px solid rgba(139, 92, 246, 0.5)' }}>
                  Sign Out
                </button>
              </li>
            </>
          ) : (
            <li>
              <button className="nav-btn" onClick={() => { navigateTo('login'); setMobileMenuOpen(false); }}>
                Login
              </button>
            </li>
          )}
        </ul>

        <button
          className="mobile-menu-btn"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
        >
          ☰
        </button>
      </div>
    </nav>
  );
}

export default Navbar;
