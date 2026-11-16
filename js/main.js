document.documentElement.classList.add("js");
(function () {
  var WHATS = "5534988387442",
    EMAIL = "contato.nex7step@gmail.com",
    $ = function (id) {
      return document.getElementById(id);
    },
    nav = document.querySelector("nav"),
    burger = document.querySelector(".burger");

  burger.onclick = function () {
    burger.setAttribute("aria-expanded", nav.classList.toggle("open"));
  };
  nav.onclick = function (e) {
    if (e.target.tagName === "A") {
      nav.classList.remove("open");
      burger.setAttribute("aria-expanded", "false");
    }
  };

  var hd = document.querySelector("header");
  function sc() { hd.classList.toggle("sc", window.scrollY > 10); }
  sc(); window.addEventListener("scroll", sc, { passive: true });

  var io = "IntersectionObserver" in window ? new IntersectionObserver(function (es) {
    es.forEach(function (e) { if (e.isIntersecting) { e.target.classList.add("in"); io.unobserve(e.target); } });
  }, { threshold: 0.12, rootMargin: "0px 0px -40px 0px" }) : null;
  window.nexReveal = function (root) {
    var els = (root || document).querySelectorAll(".rv:not(.in)");
    Array.prototype.forEach.call(els, function (el, i) {
      el.style.setProperty("--d", (i % 4) * 0.08 + "s");
      io ? io.observe(el) : el.classList.add("in");
    });
  };
  window.nexReveal();

  if (!$("bw")) return;
  function texto() {
    var n = $("nome").value.trim(),
      m = $("msg").value.trim();
    return "Olá! Meu nome é " + (n || "(sem nome)") + ". " + (m || "Gostaria de um orçamento.");
  }
  $("bw").onclick = function () {
    window.open("https://wa.me/" + WHATS + "?text=" + encodeURIComponent(texto()), "_blank", "noopener");
  };
  $("be").onclick = function () {
    location.href =
      "mailto:" + EMAIL + "?subject=" + encodeURIComponent("Contato pelo site") + "&body=" + encodeURIComponent(texto());
  };
})();
