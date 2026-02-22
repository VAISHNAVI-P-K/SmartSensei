<template>
    <nav class="navbar">
        <div class="navbar-container">
            <router-link to="/" class="navbar-logo">MyApp</router-link>
            
            <div 
                :class="['hamburger', { active: isMenuOpen }]"
                @click="toggleMenu"
            >
                <span class="bar"></span>
                <span class="bar"></span>
                <span class="bar"></span>
            </div>

            <ul :class="['navbar-menu', { active: isMenuOpen }]">
                <li v-for="item in menuItems" :key="item.path" class="navbar-item">
                    <router-link 
                        :to="item.path"
                        class="navbar-link"
                        @click="isMenuOpen = false"
                    >
                        {{ item.label }}
                    </router-link>
                </li>
                <li class="navbar-item">
                    <router-link 
                        to="/login"
                        class="navbar-link navbar-cta"
                        @click="isMenuOpen = false"
                    >
                        Login
                    </router-link>
                </li>
            </ul>
        </div>
    </nav>
</template>

<script>
export default {
    name: 'Navbar',
    data() {
        return {
            isMenuOpen: false,
            menuItems: [
                { label: 'Home', path: '/' },
                { label: 'About', path: '/about' },
                { label: 'Services', path: '/services' },
                { label: 'Products', path: '/products' },
                { label: 'Contact', path: '/contact' },
            ]
        };
    },
    methods: {
        toggleMenu() {
            this.isMenuOpen = !this.isMenuOpen;
        }
    }
};
</script>

<style scoped>
/* Use the CSS from style.css above */
</style>