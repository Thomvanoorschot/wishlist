export const Copy = {
  mounted() {
    let { to } = this.el.dataset;

    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();

      navigator.clipboard.writeText(to).then(() => {
        // 1) Create a container <div> that LiveToast will recognize
        const toast = document.createElement("div");

        // Generate a unique ID for the toast
        const uniqueId = "toast-" + Date.now();
        toast.id = uniqueId;

        // 2) Mark it with the LiveToast hook, so it gets the same JS animations
        toast.setAttribute("phx-hook", "LiveToast");

        // 3) Provide a data-duration so it auto-hides in X ms
        toast.setAttribute("data-duration", "6000"); // same default as your library
        toast.setAttribute("data-corner", "bottom_right"); // or whichever corner you use

        // 4) Apply the same classes your library uses (see `LiveToast.toast_class_fn/1`)
        toast.className =
          // The base classes from your default LiveToast styling:
          "text-black !bg-green-100 border-green-200 group/toast z-100 pointer-events-auto relative " +
          "w-full items-center justify-between origin-center overflow-hidden " +
          "rounded-lg p-4 shadow-lg border col-start-1 col-end-1 row-start-1 " +
          "row-end-2 [@media(scripting:enabled)]:opacity-0 " +
          "[@media(scripting:enabled){[data-phx-main]_&}]:opacity-100 flex text-black";

        toast.setAttribute("role", "alert");

        // 5) Build the inner text/body
        const contentDiv = document.createElement("div");
        contentDiv.className = "grow flex flex-col items-start justify-center";

        const bodyP = document.createElement("p");
        bodyP.className = "text-sm leading-5";
        bodyP.textContent = "Copied URL to clipboard!";
        contentDiv.appendChild(bodyP);

        // 6) Add a CLOSE BUTTON, but do *NOT* rely on phx-click="clear"
        //    Instead, handle removal purely client-side.
        const closeBtn = document.createElement("button");
        closeBtn.type = "button";
        closeBtn.setAttribute("aria-label", "close");
        closeBtn.className = [
          "absolute right-[5px] top-[5px] rounded-md p-[5px]",
          "text-black/50 transition-opacity hover:text-black focus:opacity-100",
          "focus:outline-none focus:ring-1 group group-hover:opacity-100",
        ].join(" ");

        // On click, fade out & remove the toast purely client-side.
        closeBtn.addEventListener("click", (e) => {
          e.preventDefault();
          animateOutAndRemove(toast);
        });

        // 7) Append everything into the toast
        toast.appendChild(contentDiv);
        toast.appendChild(closeBtn);

        // 8) Put it inside the same #toast-group container
        const toastGroup = document.getElementById("toast-group");
        if (toastGroup) {
          toastGroup.appendChild(toast);
        } else {
          console.warn("Toast group container not found!");
        }

        // After 1s, fade out and remove automatically
        const durationOverride = 1000;
        window.setTimeout(() => {
          animateOutAndRemove(toast);
        }, durationOverride);
      });
    });

    // Simple helper to animate out and remove the toast
    function animateOutAndRemove(toastEl: HTMLElement) {
      // Apply some quick fade-out. Could use motion-one or normal CSS transitions.
      // For example, we can just set style.transition and style.opacity:
      toastEl.style.transition = "opacity 0.3s ease-out";
      toastEl.style.opacity = "0";

      // Then remove from DOM after the animation
      setTimeout(() => {
        toastEl.remove();
      }, 300);
    }
  },
};
