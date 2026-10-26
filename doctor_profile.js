(() => {
    const targets = document.querySelectorAll('.page-header-banner, .form-card');
    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reducedMotion || !('IntersectionObserver' in window)) {
        targets.forEach((item) => item.classList.add('doctor-animate-in'));
    } else {
        const observer = new IntersectionObserver((entries) => entries.forEach((entry) => {
            if (!entry.isIntersecting) return;
            entry.target.classList.add('doctor-animate-in');
            observer.unobserve(entry.target);
        }), { threshold: 0.12 });
        targets.forEach((item, index) => {
            item.classList.add('doctor-animate');
            item.style.setProperty('--doctor-delay', `${index * 85}ms`);
            observer.observe(item);
        });
    }

    const photoFile = document.getElementById('profilePhotoFile');
    const photo = document.getElementById('profilePhoto');
    const photoStatus = document.getElementById('profilePhotoStatus');
    let previewUrl = null;

    document.addEventListener('DOMContentLoaded', async () => {
        const today = localDate();
        const start = document.getElementById('leaveStartDate');
        const end = document.getElementById('leaveEndDate');
        start.min = today;
        end.min = today;
        start.addEventListener('change', () => { end.min = start.value || today; });
        document.getElementById('updateDoctorProfile').addEventListener('click', updateDoctorProfile);
        document.getElementById('submitDoctorLeave').addEventListener('click', submitDoctorLeave);
        document.getElementById('uploadProfilePhoto').addEventListener('click', uploadPhoto);
        document.getElementById('deleteProfilePhoto').addEventListener('click', deletePhoto);
        photoFile.addEventListener('change', previewPhoto);

        try {
            const data = await VaxApi.get('doctor_profile_backend.php');
            if (data.status !== 'success') throw new Error(data.message || 'Your profile is unavailable.');
            document.getElementById('fullName').value = data.fullName;
            document.getElementById('email').value = data.email;
            document.getElementById('specialization').value = data.specialization || '';
            document.getElementById('consultationRoom').value = data.consultationRoom || '';
            document.getElementById('welcome-message').textContent = `Welcome back, ${data.fullName}. Manage your personal details and leave requests.`;
            document.getElementById('profileInitials').textContent = initials(data.fullName);
            document.getElementById('deleteProfilePhoto').disabled = !data.hasPhoto;
            if (data.hasPhoto) loadStoredPhoto();
        } catch (error) {
            document.getElementById('welcome-message').textContent = error.message || 'Could not load your profile. Please refresh to try again.';
        }
    });

    function localDate() {
        const now = new Date();
        return `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
    }
    function initials(name) { return name.replace(/^Dr\.\s*/i, '').split(/\s+/).map((part) => part[0]).slice(0, 2).join('').toUpperCase() || 'DR'; }
    function loadStoredPhoto() {
        photo.onload = () => { photo.hidden = false; document.getElementById('profileInitials').hidden = true; };
        photo.onerror = () => { photo.hidden = true; document.getElementById('profileInitials').hidden = false; };
        photo.src = `doctor_profile_backend.php?action=profile_photo&v=${Date.now()}`;
    }
    function previewPhoto() {
        photoStatus.textContent = '';
        if (previewUrl) URL.revokeObjectURL(previewUrl);
        if (!photoFile.files[0]) return;
        previewUrl = URL.createObjectURL(photoFile.files[0]);
        photo.src = previewUrl;
        photo.hidden = false;
        document.getElementById('profileInitials').hidden = true;
    }
    async function uploadPhoto() {
        const file = photoFile.files[0];
        if (!file) { photoStatus.textContent = 'Choose a profile photo first.'; return; }
        if (!['image/jpeg', 'image/png', 'image/webp'].includes(file.type) || file.size > 2 * 1024 * 1024) {
            photoStatus.textContent = 'Choose a JPEG, PNG, or WebP image up to 2 MB.';
            return;
        }
        const button = document.getElementById('uploadProfilePhoto');
        button.disabled = true;
        photoStatus.textContent = 'Uploading photo…';
        const data = new FormData();
        data.append('action', 'upload_photo');
        data.append('photo', file);
        try {
            const result = await VaxApi.postFormData('doctor_profile_backend.php', data);
            if (result.status !== 'success') throw new Error(result.message || 'The profile photo could not be saved.');
            photoStatus.textContent = result.message;
            document.getElementById('deleteProfilePhoto').disabled = false;
            document.dispatchEvent(new CustomEvent('vaxassist:doctor-photo-updated', { detail: { hasPhoto: true } }));
            if (previewUrl) { URL.revokeObjectURL(previewUrl); previewUrl = null; }
            loadStoredPhoto();
            photoFile.value = '';
        } catch (error) {
            photoStatus.textContent = error.message || 'The profile photo could not be saved.';
        } finally {
            button.disabled = false;
        }
    }
    async function deletePhoto() {
        if (!window.confirm('Delete your profile photo?')) return;
        const button = document.getElementById('deleteProfilePhoto');
        button.disabled = true;
        photoStatus.textContent = 'Deleting photo…';
        try {
            const result = await VaxApi.post('doctor_profile_backend.php', { action: 'delete_photo' });
            if (result.status !== 'success') throw new Error(result.message || 'The profile photo could not be deleted.');
            if (previewUrl) { URL.revokeObjectURL(previewUrl); previewUrl = null; }
            photoFile.value = '';
            photo.hidden = true;
            photo.removeAttribute('src');
            document.getElementById('profileInitials').hidden = false;
            photoStatus.textContent = result.message;
            document.dispatchEvent(new CustomEvent('vaxassist:doctor-photo-updated', { detail: { hasPhoto: false } }));
        } catch (error) {
            photoStatus.textContent = error.message || 'The profile photo could not be deleted.';
            button.disabled = false;
        }
    }
    async function updateDoctorProfile() {
        const payload = {
            action: 'update_profile',
            specialization: document.getElementById('specialization').value,
            room: document.getElementById('consultationRoom').value
        };
        try {
            const data = await VaxApi.post('doctor_profile_backend.php', payload);
            alert(data.message || 'Profile updated.');
        } catch (error) { alert(error.message || 'Could not update your profile.'); }
    }
    async function submitDoctorLeave() {
        const form = document.getElementById('leaveForm');
        if (!form.reportValidity()) return;
        const payload = {
            action: 'submit_leave',
            start_date: document.getElementById('leaveStartDate').value,
            end_date: document.getElementById('leaveEndDate').value,
            reason: document.getElementById('leaveReason').value
        };
        try {
            const data = await VaxApi.post('doctor_profile_backend.php', payload);
            alert(data.message || 'Leave request sent.');
            if (data.status === 'success') form.reset();
        } catch (error) { alert(error.message || 'Could not submit your leave request.'); }
    }
})();
