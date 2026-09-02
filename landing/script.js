// ============================================================
// Attendify Landing Page — Premium JS
// ============================================================

// ── Particles ──────────────────────────────────────────────
(function initParticles() {
  const canvas = document.getElementById('particles-canvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  let particles = [], W, H, animId;

  function resize() {
    W = canvas.width = window.innerWidth;
    H = canvas.height = window.innerHeight;
  }

  function createParticle() {
    return {
      x: Math.random() * W,
      y: Math.random() * H,
      r: Math.random() * 1.5 + 0.5,
      dx: (Math.random() - 0.5) * 0.3,
      dy: (Math.random() - 0.5) * 0.3,
      alpha: Math.random() * 0.4 + 0.05,
      color: Math.random() > 0.5 ? '108,99,255' : '0,212,255'
    };
  }

  function init() {
    particles = [];
    const count = Math.min(Math.floor(W * H / 15000), 80);
    for (let i = 0; i < count; i++) particles.push(createParticle());
  }

  function draw() {
    ctx.clearRect(0, 0, W, H);
    particles.forEach(p => {
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(' + p.color + ',' + p.alpha + ')';
      ctx.fill();
      p.x += p.dx;
      p.y += p.dy;
      if (p.x < -10) p.x = W + 10;
      if (p.x > W + 10) p.x = -10;
      if (p.y < -10) p.y = H + 10;
      if (p.y > H + 10) p.y = -10;
    });
    animId = requestAnimationFrame(draw);
  }

  window.addEventListener('resize', () => { resize(); init(); });
  resize(); init(); draw();
})();

// ── Nav scroll effect ───────────────────────────────────────
(function initNav() {
  const nav = document.querySelector('nav');
  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 30);
  }, { passive: true });
})();

// ── Mobile menu ─────────────────────────────────────────────
(function initMobileMenu() {
  const hamburger = document.querySelector('.hamburger');
  const mobileMenu = document.querySelector('.mobile-menu');
  if (!hamburger || !mobileMenu) return;

  hamburger.addEventListener('click', () => {
    const open = mobileMenu.classList.toggle('open');
    hamburger.setAttribute('aria-expanded', open);
    // animate bars
    const bars = hamburger.querySelectorAll('span');
    if (open) {
      bars[0].style.transform = 'rotate(45deg) translate(5px,5px)';
      bars[1].style.opacity = '0';
      bars[2].style.transform = 'rotate(-45deg) translate(5px,-5px)';
    } else {
      bars[0].style.transform = '';
      bars[1].style.opacity = '';
      bars[2].style.transform = '';
    }
  });

  mobileMenu.querySelectorAll('a').forEach(a => {
    a.addEventListener('click', () => {
      mobileMenu.classList.remove('open');
      const bars = hamburger.querySelectorAll('span');
      bars[0].style.transform = '';
      bars[1].style.opacity = '';
      bars[2].style.transform = '';
    });
  });
})();

// ── Scroll Reveal (smooth) ────────────────────────────────────
(function initReveal() {
  const els = document.querySelectorAll('.reveal');
  if (!els.length) return;
  const io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        e.target.classList.add('visible');
        io.unobserve(e.target);
      }
    });
  }, {
    threshold: 0.08,
    rootMargin: '0px 0px -40px 0px'
  });
  els.forEach(el => io.observe(el));
})();

// ── Phone Screen Carousel (Auto-play) ───────────────────────
(function initPhoneCarousel() {
  const carousel = document.querySelector('.phone-screen-carousel');
  if (!carousel) return;
  const total = carousel.querySelectorAll('img').length;
  let current = 0, interval;

  function goTo(idx) {
    current = (idx + total) % total;
    carousel.style.transform = 'translateX(-' + (current * (100 / total)) + '%)';
  }

  interval = setInterval(() => goTo(current + 1), 2800);
  carousel.parentElement.addEventListener('mouseenter', () => clearInterval(interval));
  carousel.parentElement.addEventListener('mouseleave', () => {
    clearInterval(interval);
    interval = setInterval(() => goTo(current + 1), 2800);
  });
})();


// ── Screenshots Drag Scroll + Dots ───────────────────────────
(function initDragScroll() {
  const track = document.getElementById('screenshots-track');
  const dots = document.querySelectorAll('#screenshots-dots span');
  if (!track) return;

  // Update active dot based on scroll position
  function updateDots() {
    if (!dots.length) return;
    const cards = track.querySelectorAll('.screenshot-card');
    const cardW = cards[0] ? cards[0].offsetWidth + 16 : 246; // 230 + 16 gap
    const idx = Math.round(track.scrollLeft / cardW);
    dots.forEach((d, i) => d.classList.toggle('active', i === idx));
  }

  track.addEventListener('scroll', updateDots, { passive: true });

  // Dot click → scroll to that card
  dots.forEach((dot, i) => {
    dot.addEventListener('click', () => {
      const cards = track.querySelectorAll('.screenshot-card');
      const cardW = cards[0] ? cards[0].offsetWidth + 16 : 246;
      track.scrollTo({ left: i * cardW, behavior: 'smooth' });
    });
  });

  // Drag scroll (mouse)
  let down = false, startX, scrollLeft;
  track.addEventListener('mousedown', e => {
    down = true; startX = e.pageX - track.offsetLeft; scrollLeft = track.scrollLeft;
    track.style.userSelect = 'none'; track.style.cursor = 'grabbing';
  });
  track.addEventListener('mouseleave', () => { down = false; track.style.cursor = 'grab'; });
  track.addEventListener('mouseup', () => { down = false; track.style.userSelect = ''; track.style.cursor = 'grab'; });
  track.addEventListener('mousemove', e => {
    if (!down) return;
    const x = e.pageX - track.offsetLeft;
    track.scrollLeft = scrollLeft - (x - startX) * 1.5;
  });

  // Touch support
  let touchStartX = 0, touchScrollLeft = 0;
  track.addEventListener('touchstart', e => {
    touchStartX = e.touches[0].pageX;
    touchScrollLeft = track.scrollLeft;
  }, { passive: true });
  track.addEventListener('touchmove', e => {
    const walk = (touchStartX - e.touches[0].pageX) * 1.5;
    track.scrollLeft = touchScrollLeft + walk;
  }, { passive: true });
})();

// ── Stats Counter Animation ──────────────────────────────────
(function initCounters() {
  const counters = document.querySelectorAll('[data-count]');
  if (!counters.length) return;

  const io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (!e.isIntersecting) return;
      const el = e.target;
      const target = parseInt(el.dataset.count);
      const suffix = el.dataset.suffix || '';
      const duration = 1600;
      const start = performance.now();

      function step(now) {
        const progress = Math.min((now - start) / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        el.textContent = Math.floor(eased * target) + suffix;
        if (progress < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
      io.unobserve(el);
    });
  }, { threshold: 0.5 });

  counters.forEach(c => io.observe(c));
})();

// ── Smooth anchor scroll ─────────────────────────────────────
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    const target = document.querySelector(a.getAttribute('href'));
    if (!target) return;
    e.preventDefault();
    target.scrollIntoView({ behavior: 'smooth', block: 'start' });
  });
});
