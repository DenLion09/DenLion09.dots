document.querySelector("menu-toggle").addEventListener("click", () => {
  document.querySelector(".nav-links").classList.toggle("active");
});

window.addEventListener("scroll", () => {
  const header = document.querySelector("header");

  if (window.sclollY > 50) {
    header.classList.add("scrolled");
  } else {
    header.classList.remove("scrolled");
  }
});
