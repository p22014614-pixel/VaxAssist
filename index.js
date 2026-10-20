const tabs = document.querySelectorAll(".planner-tab");
const mode = document.getElementById("plannerMode");
const travelField = document.getElementById("travelField");
const childField = document.getElementById("childField");
const destination = document.getElementById("destination");
const childDob = document.getElementById("childDob");

childDob.max = new Date().toISOString().split("T")[0];

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
