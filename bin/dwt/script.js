/* Don't Waste Time — site awareness, fractal tree, current time. */
(function () {
  "use strict";

  var reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* --- Where were you going? ------------------------------------------- */

  var SITES = [
    { match: "reddit",    line: "You were about to open Reddit." },
    { match: "youtube",   line: "You were about to start watching." },
    { match: "twitch",    line: "You were about to start watching." },
    { match: "instagram", line: "You were about to start scrolling." },
    { match: "tiktok",    line: "You were about to start scrolling." },
    { match: "facebook",  line: "You were about to start scrolling." },
    { match: "twitter",   line: "You were about to start scrolling." },
    { match: "x.com",     line: "You were about to start scrolling." },
    { match: "news",      line: "You were about to start doomscrolling." }
  ];

  var host = (location.hostname || "").toLowerCase().replace(/^www\./, "");
  var siteLine = document.getElementById("site-line");

  if (siteLine) {
    for (var i = 0; i < SITES.length; i++) {
      if (host.indexOf(SITES[i].match) !== -1) {
        siteLine.textContent = SITES[i].line;
        break;
      }
    }
  }

  /* --- Fractal tree: seeded shape, grows in, sways ---------------------- */

  var MAX_DEPTH = 8;
  var GROW_MS = 2600;
  var HOLD_MS = 2200;
  var FADE_MS = 600;

  function mulberry32(seed) {
    return function () {
      seed |= 0; seed = seed + 0x6D2B79F5 | 0;
      var t = Math.imul(seed ^ seed >>> 15, 1 | seed);
      t = t + Math.imul(t ^ t >>> 7, 61 | t) ^ t;
      return ((t ^ t >>> 14) >>> 0) / 4294967296;
    };
  }

  var canvas = document.getElementById("tree");

  if (canvas && canvas.getContext) {
    var ctx = canvas.getContext("2d");
    var root = null;
    var unit = 0;
    var cycleStart = 0;

    function buildTree() {
      var rand = mulberry32(7);
      function branch(depth, len, angle) {
        var node = { depth: depth, len: len, angle: angle,
                     phase: rand() * Math.PI * 2, children: [] };
        if (depth < MAX_DEPTH) {
          var n = rand() < 0.25 ? 1 : (rand() < 0.1 ? 3 : 2);
          var spread = 0.34 + rand() * 0.2;
          var decay = 0.72 + rand() * 0.06;
          for (var i = 0; i < n; i++) {
            var side = n === 1 ? (rand() - 0.5) * 0.3 : (i / (n - 1)) * 2 - 1;
            var a = angle + side * spread + (rand() - 0.5) * 0.18;
            node.children.push(branch(depth + 1, len * decay, a));
          }
        }
        return node;
      }
      root = branch(0, 1, -Math.PI / 2);
    }

    function lerp(a, b, k) { return a + (b - a) * k; }

    function drawNode(node, x, y, growLevel, t) {
      var d = node.depth;
      var vis = growLevel - d;
      if (vis <= 0) return;

      var k = d / MAX_DEPTH;
      var sway = d === 0 ? 0 :
        (Math.sin(t * 0.0012 + d * 0.7) * 0.012 +
         Math.sin(t * 0.0005 + d * 0.3) * 0.008) * k;
      var a = node.angle + sway;
      var len = node.len * unit * Math.min(1, vis);
      var x2 = x + Math.cos(a) * len;
      var y2 = y + Math.sin(a) * len;

      ctx.strokeStyle = "rgba(" +
        Math.round(lerp(112, 168, k)) + "," +
        Math.round(lerp(107, 108, k)) + "," +
        Math.round(lerp(100, 104, k)) + "," +
        (0.92 - 0.4 * k).toFixed(3) + ")";
      ctx.lineWidth = lerp(3.2, 0.6, k);
      ctx.lineCap = "round";
      ctx.beginPath();
      ctx.moveTo(x, y);
      ctx.lineTo(x2, y2);
      ctx.stroke();

      if (d === MAX_DEPTH) {
        var alpha = Math.min(1, vis) * (0.35 + 0.3 * Math.sin(t * 0.0023 + node.phase));
        if (alpha > 0.03) {
          ctx.fillStyle = "rgba(186, 84, 66, " + alpha.toFixed(3) + ")";
          ctx.beginPath();
          ctx.arc(x2, y2, 1.6, 0, Math.PI * 2);
          ctx.fill();
        }
        return;
      }

      for (var i = 0; i < node.children.length; i++) {
        drawNode(node.children[i], x2, y2, growLevel, t);
      }
    }

    function sizeCanvas() {
      var dpr = window.devicePixelRatio || 1;
      var w = canvas.clientWidth;
      var h = canvas.clientHeight;
      canvas.width = Math.round(w * dpr);
      canvas.height = Math.round(h * dpr);
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      unit = Math.min(w * 0.22, h * 0.235);
    }

    function render(t) {
      ctx.clearRect(0, 0, canvas.clientWidth, canvas.clientHeight);
      var w = canvas.clientWidth;
      var h = canvas.clientHeight;

      /* Loop: grow → hold → fade → regrow */
      var cycle = GROW_MS + HOLD_MS;
      var elapsed = t - cycleStart;
      if (elapsed >= cycle) {
        cycleStart = t;
        elapsed = 0;
      }
      var p = Math.min(1, elapsed / GROW_MS);
      var eased = 1 - Math.pow(1 - p, 3);
      var fadeFrom = cycle - FADE_MS;
      var alpha = elapsed > fadeFrom ? Math.max(0, 1 - (elapsed - fadeFrom) / FADE_MS) : 1;

      ctx.globalAlpha = alpha;
      drawNode(root, w / 2, h - 6, eased * MAX_DEPTH, t);
      ctx.globalAlpha = 1;
    }

    buildTree();
    sizeCanvas();
    cycleStart = performance.now();

    if (reduceMotion) {
      render(GROW_MS + 1);
    } else {
      (function loop(t) {
        render(t);
        requestAnimationFrame(loop);
      })(cycleStart);
    }

    window.addEventListener("resize", function () {
      sizeCanvas();
      if (reduceMotion) render(GROW_MS + 1);
    });
  }

  /* --- Current time line ------------------------------------------------- */

  var timeEl = document.getElementById("currentTime");

  function updateTime() {
    var now = new Date();
    var t = now.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit", hour12: true });
    var d = now.toLocaleDateString("en-US", { weekday: "long" });
    if (timeEl) timeEl.textContent = "It\u2019s " + t + " on " + d + ".";
  }

  updateTime();
  window.setInterval(updateTime, 1000);
})();
