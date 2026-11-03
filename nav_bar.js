// Loads the shared doctor navigation fragment and activates the link for the current page.
(function () {
    const placeholder = document.querySelector('[data-doctor-nav]');
    if (!placeholder) return;

    fetch('nav_bar.html?v=2', { credentials: 'same-origin' })
        .then((response) => {
            if (!response.ok) throw new Error('Could not load shared doctor navigation.');
            return response.text();
        })
        .then((html) => {
            placeholder.innerHTML = html;
            const currentPage = location.pathname.split('/').pop().toLowerCase();
            placeholder.querySelectorAll('.nav-link[href]').forEach((link) => {
                if (link.getAttribute('href').toLowerCase() === currentPage) {
                    link.classList.add('active');
                    link.setAttribute('aria-current', 'page');
                }
            });
            placeholder.dispatchEvent(new CustomEvent('vaxassist:doctor-nav-ready', { bubbles: true }));
        })
        .catch((error) => console.error(error));
})();
