import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './Navbar.css';

const Navbar = () => {
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const navigate = useNavigate();

    const menuItems = [
        { label: 'Home', path: '/' },
        { label: 'About', path: '/about' },
        { label: 'Services', path: '/services' },
        { label: 'Products', path: '/products' },
        { label: 'Contact', path: '/contact' },
    ];

    const handleNavigation = (path) => {
        navigate(path);
        setIsMenuOpen(false);
    };

    const toggleMenu = () => {
        setIsMenuOpen(!isMenuOpen);
    };

    return (
        <nav className="navbar">
            <div className="navbar-container">
                <div className="navbar-logo" onClick={() => handleNavigation('/')}>
                    MyApp
                </div>
                
                <div className={`hamburger ${isMenuOpen ? 'active' : ''}`} onClick={toggleMenu}>
                    <span className="bar"></span>
                    <span className="bar"></span>
                    <span className="bar"></span>
                </div>

                <ul className={`navbar-menu ${isMenuOpen ? 'active' : ''}`}>
                    {menuItems.map((item) => (
                        <li key={item.path} className="navbar-item">
                            <button 
                                className="navbar-link"
                                onClick={() => handleNavigation(item.path)}
                            >
                                {item.label}
                            </button>
                        </li>
                    ))}
                    <li className="navbar-item">
                        <button 
                            className="navbar-link navbar-cta"
                            onClick={() => handleNavigation('/login')}
                        >
                            Login
                        </button>
                    </li>
                </ul>
            </div>
        </nav>
    );
};

export default Navbar;