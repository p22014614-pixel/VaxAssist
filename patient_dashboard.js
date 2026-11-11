const tabs = document.querySelectorAll(".planner-tab");
const mode = document.getElementById("plannerMode");
const travelField = document.getElementById("travelField");
const childField = document.getElementById("childField");
const destination = document.getElementById("destination");
const childDob = document.getElementById("childDob");

// The home page is the patient landing page. Send authenticated doctors to their portal.
VaxAuth.fetchUser().then(function (user) {
    if (user && user.role === "doctor") {
        window.location.replace(VaxAuth.getDashboardForRole(user.role));
    }
});

childDob.max = new Date(Date.now() - new Date().getTimezoneOffset() * 60000).toISOString().split("T")[0]; // local date, not UTC

tabs.forEach(function (tab) {
    tab.addEventListener("click", function () {
        const isTravel = tab.dataset.mode === "travel";

        tabs.forEach(function (t) {
            const active = t === tab;
            t.classList.toggle("active", active);
            t.setAttribute("aria-selected", active);
        });

        mode.value = tab.dataset.mode;
        travelField.classList.toggle("d-none", !isTravel);
        childField.classList.toggle("d-none", isTravel);

        destination.required = isTravel;
        destination.disabled = !isTravel;
        childDob.required = !isTravel;
        childDob.disabled = isTravel;
    });
});

childDob.disabled = true;
