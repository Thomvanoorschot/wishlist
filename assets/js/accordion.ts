export const Accordion = {
  mounted() {
    const wishlistId = this.el.dataset.wishlistId; // e.g. "123"
    const defaultOpen = this.el.dataset.defaultOpen === "true";

    let stored = localStorage.getItem(`accordion-${wishlistId}-open`);
    let isOpen = stored === null ? defaultOpen : JSON.parse(stored) === true;

    const trigger = this.el.querySelector("details");

    if (isOpen) {
      trigger.setAttribute("open", "");
    }

    if (trigger) {
      trigger.addEventListener("click", (ev) => {
        if (ev.target.closest("button, a")) {
          return;
        }

        ev.preventDefault();

        isOpen = !isOpen;
        trigger.open = isOpen;
        localStorage.setItem(
          `accordion-${wishlistId}-open`,
          JSON.stringify(isOpen)
        );
      });
    }
  },
};
