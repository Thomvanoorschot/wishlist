export const SearchModalWishlistId = {
  setWishlistAttributes() {
    this.el.setAttribute("phx-value-wishlist_id", "some-value");

    let selected = document.getElementById("selected_wishlist");
    if (!selected) return;

    let wishlistId = selected.getAttribute("wishlist_id");
    if (wishlistId) {
      this.el.setAttribute("phx-value-wishlist_id", wishlistId);
    }
  },

  mounted() {
    console.log("MyCustomHook mounted!");
    this.setWishlistAttributes();
  },

  updated() {
    console.log("MyCustomHook updated!");
    this.setWishlistAttributes();
  },
};
