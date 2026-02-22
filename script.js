const hamburger = document.querySelector('.hamburger');
const navbarMenu = document.querySelector('.navbar-menu');
const navbarLinks = document.querySelectorAll('.navbar-link');

// Toggle mobile menu
hamburger.addEventListener('click', () => {
    hamburger.classList.toggle('active');
    navbarMenu.classList.toggle('active');
});

// Close menu when a link is clicked
navbarLinks.forEach(link => {
    link.addEventListener('click', () => {
        hamburger.classList.remove('active');
        navbarMenu.classList.remove('active');
    });
});