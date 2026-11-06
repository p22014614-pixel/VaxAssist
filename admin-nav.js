(function () {
    const mount = document.getElementById('adminNavMount');
    if (!mount) return;

    fetch('admin_nav.html', { cache: 'no-cache' })
        .then((response) => {
            if (!response.ok) throw new Error('Could not load admin navigation.');
            return response.text();
        })
        .then((markup) => {
            mount.innerHTML = markup;
            const currentPage = location.pathname.split('/').pop().toLowerCase();
            mount.querySelectorAll('.main-admin-link').forEach((link) => {
                if (link.getAttribute('href').toLowerCase() === currentPage) {
                    link.classList.add('active');
                    link.setAttribute('aria-current', 'page');
                }
            });
            if (currentPage === 'admin_profile.html') {
                const profile = mount.querySelector('.avatar-link');
                profile.classList.add('active');
                profile.setAttribute('aria-current', 'page');
            }
            const toggle = mount.querySelector('#adminNavToggle');
            const links = mount.querySelector('#adminNavLinks');
            toggle.addEventListener('click', () => {
                const open = toggle.getAttribute('aria-expanded') !== 'true';
                toggle.setAttribute('aria-expanded', String(open));
                links.classList.toggle('open', open);
            });
        })
        .catch((error) => console.error(error));
})();
