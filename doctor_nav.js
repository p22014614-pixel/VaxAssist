// Loads the signed-in doctor's initials or saved photo into each page's navigation bar.
(() => {
    const initials = document.querySelectorAll('[data-doctor-initials]');
    const photos = document.querySelectorAll('[data-doctor-photo]');
    let hasPhoto = false;

    // Creates a short name fallback for navigation when no image is available.
    function setInitials(name) {
        const letters = String(name || 'Doctor').replace(/^Dr\.\s*/i, '').trim().split(/\s+/).map((part) => part[0]).slice(0, 2).join('').toUpperCase() || 'DR';
        initials.forEach((item) => { item.textContent = letters; item.hidden = false; });
    }

    // Shows the doctor's latest stored photo or returns to the initials fallback.
    function refreshPhoto() {
        if (!hasPhoto) {
            photos.forEach((image) => { image.hidden = true; image.removeAttribute('src'); });
            initials.forEach((item) => { item.hidden = false; });
            return;
        }
        photos.forEach((image) => {
            image.onload = () => { image.hidden = false; const fallback = image.parentElement.querySelector('[data-doctor-initials]'); if (fallback) fallback.hidden = true; };
            image.onerror = () => { image.hidden = true; const fallback = image.parentElement.querySelector('[data-doctor-initials]'); if (fallback) fallback.hidden = false; };
            image.src = `doctor_profile_backend.php?action=profile_photo&v=${Date.now()}`;
        });
    }

    document.addEventListener('DOMContentLoaded', async () => {
        const cachedUser = window.VaxAuth?.getUser?.();
        setInitials(cachedUser ? `Dr. ${cachedUser.first_name || ''} ${cachedUser.last_name || ''}` : 'Doctor');
        try {
            const profile = await window.VaxApi.get('doctor_profile_backend.php');
            if (profile.status === 'success') {
                setInitials(profile.fullName);
                hasPhoto = profile.hasPhoto;
                refreshPhoto();
            }
        } catch (error) {
            console.warn('Could not load the doctor navigation photo.', error);
        }
    });

    document.addEventListener('vaxassist:doctor-photo-updated', (event) => {
        hasPhoto = Boolean(event.detail && event.detail.hasPhoto);
        refreshPhoto();
    });
})();
