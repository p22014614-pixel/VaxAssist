// Scroll animation shared by all pages.

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
        '.doctor-portal .page-header-banner', '.doctor-portal .dashboard-report > h2',
        '.doctor-portal .doctor-page-heading .container',
        '.doctor-portal .analytics-card', '.doctor-portal .nav-card-link',
        '.doctor-portal .filter-bar', '.doctor-portal .week-calendar-container',
        '.doctor-portal .month-calendar-container', '.doctor-portal .chat-layout',
        '.doctor-portal .chat-sidebar', '.doctor-portal .chat-main',
        '.doctor-portal .vaccination-patient-card', '.doctor-portal .precheck-details',
        '.doctor-portal .patient-update-item',
        '.page-header .container.text-center',
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

    // Marks a section for the scroll animation.
    function register(el) {
        if (el.classList.contains('reveal') || el.closest('.modal')) return;
        const parent = el.parentElement && el.parentElement.closest('.reveal');
        if (parent) return;
        if (getComputedStyle(el).animationName !== 'none') return;
        el.classList.add('reveal');
        observer.observe(el);
    }

    // Finds sections to animate inside an element.
    function scan(root) {
        if (root.nodeType !== 1) return;
        if (root.matches(SELECTORS)) register(root);
        root.querySelectorAll(SELECTORS).forEach(register);
    }

    // Starts the scroll animation and watches for new content.
    function start() {
        scan(document.body);
        new MutationObserver(function (mutations) {
            mutations.forEach(function (m) { m.addedNodes.forEach(scan); });
        }).observe(document.body, { childList: true, subtree: true });
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
    else start();
})();

(function () {
    let nav = null;
    let scrollHandler = null;
    const updateNav = function () {
        const currentNav = document.querySelector('.navbar');
        if (!currentNav || currentNav === nav) return;
        if (scrollHandler) window.removeEventListener('scroll', scrollHandler);
        nav = currentNav;
        scrollHandler = function () { nav.classList.toggle('scrolled', window.scrollY > 8); };
        scrollHandler();
        window.addEventListener('scroll', scrollHandler, { passive: true });
    }
    updateNav();
    document.addEventListener('vaxassist:doctor-nav-ready', updateNav);

    if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

    document.addEventListener('click', function (e) {
        if (e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
        const link = e.target.closest('a[href]');
        if (!link || link.target || link.hasAttribute('download') || link.hasAttribute('data-bs-toggle') || link.hasAttribute('data-logout')) return;

        const url = new URL(link.href, window.location.href);
        if (url.origin !== window.location.origin) return;
        if (url.pathname === window.location.pathname && url.search === window.location.search) return;
        if (!/\.html$/.test(url.pathname)) return;

        e.preventDefault();
        document.body.classList.add('leaving');
        setTimeout(function () { window.location.href = link.href; }, 160);
        setTimeout(function () { document.body.classList.remove('leaving'); }, 2000);
    });

    window.addEventListener('pageshow', function (e) {
        if (e.persisted) document.body.classList.remove('leaving');
    });
})();
