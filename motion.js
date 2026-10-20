(function () {
    const reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduce || !('IntersectionObserver' in window)) return;

    document.documentElement.classList.add('js-motion');

    const SELECTORS = [
        '.hero .col-lg-6',
        '.page-header .header-row > div:first-child',
        '.section-label', '.section-title',
        '.service-card', '.step', '.about-box', '.contact-info', '.contact-item', '.cta-band',
        '.filter-card', '.doctor-card', '.appt-card',
        '.login-wrap > *', '.register-wrap > *',
        '.form-card', '.side-card', '.summary-card', '.stat-card',
        '.pay-card', '.review-card', '.vax-card', '.empty-state', '.empty-box'
    ].join(',');

    const observer = new IntersectionObserver(function (entries) {
        let n = 0;
        entries.forEach(function (entry) {
            if (!entry.isIntersecting) return;
            const el = entry.target;
            observer.unobserve(el);
            const delay = Math.min(n++, 8) * 70;
            el.style.setProperty('--d', delay + 'ms');
            el.classList.add('in');
            setTimeout(function () {
                el.classList.remove('reveal', 'in');
                el.style.removeProperty('--d');
            }, 700 + delay);
        });
    }, { threshold: 0.12, rootMargin: '0px 0px -30px 0px' });

    function register(el) {
        if (el.classList.contains('reveal') || el.closest('.modal')) return;
        const parent = el.parentElement && el.parentElement.closest('.reveal');
        if (parent) return;
        if (getComputedStyle(el).animationName !== 'none') return;
        el.classList.add('reveal');
        observer.observe(el);
    }

    function scan(root) {
        if (root.nodeType !== 1) return;
        if (root.matches(SELECTORS)) register(root);
        root.querySelectorAll(SELECTORS).forEach(register);
    }

    function start() {
        scan(document.body);
        new MutationObserver(function (mutations) {
            mutations.forEach(function (m) { m.addedNodes.forEach(scan); });
        }).observe(document.body, { childList: true, subtree: true });
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
    else start();
})();
