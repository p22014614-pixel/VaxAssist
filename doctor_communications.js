(() => {
    const targets = document.querySelectorAll(".page-header-banner, .chat-sidebar, .chat-main");
    const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    if (reducedMotion || !("IntersectionObserver" in window)) {
        targets.forEach((item) => item.classList.add("doctor-animate-in"));
        return;
    }

    const observer = new IntersectionObserver((entries) => {
        entries.forEach((entry) => {
            if (!entry.isIntersecting) return;
            entry.target.classList.add("doctor-animate-in");
            observer.unobserve(entry.target);
        });
    }, { threshold: 0.12 });

    targets.forEach((item, index) => {
        item.classList.add("doctor-animate");
        item.style.setProperty("--doctor-delay", `${index * 90}ms`);
        observer.observe(item);
    });
})();
