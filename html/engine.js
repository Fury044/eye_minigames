const MG = (function () {
    const games = {};
    let current = null;
    let raf = null;
    let timer = null;
    let ended = false;

    const $ = (id) => document.getElementById(id);

    /* ---- Lua bridge ---- */
    function post(name, body) {
        const url = `https://${resName()}/${name}`;
        fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(body || {})
        }).catch(() => {});
    }
    function resName() {
        return (typeof GetParentResourceName === 'function')
            ? GetParentResourceName() : 'eye_minigames';
    }

    /* ---- Theme ---- */
    function applyTheme(theme) {
        const r = document.documentElement.style;
        if (!theme) return;
        if (theme.accent)  r.setProperty('--accent',  theme.accent);
        if (theme.danger)  r.setProperty('--danger',  theme.danger);
        if (theme.success) r.setProperty('--success', theme.success);
        if (theme.bg)      r.setProperty('--bg',      theme.bg);
    }

    /* ---- Timer ---- */
    function startTimer(seconds, onExpire) {
        timer = { duration: seconds * 1000, start: performance.now(), onExpire };
        tick();
    }
    function tick() {
        if (!timer) return;
        const elapsed = performance.now() - timer.start;
        const remain = Math.max(0, timer.duration - elapsed);
        const pct = remain / timer.duration;
        $('timer-fill').style.width = (pct * 100) + '%';
        $('timer-text').textContent = (remain / 1000).toFixed(1);
        $('timer-fill').style.background = pct < 0.25
            ? 'linear-gradient(90deg, var(--danger), #fff)'
            : 'linear-gradient(90deg, var(--accent), #fff)';
        if (remain <= 0) {
            const fn = timer.onExpire; timer = null;
            if (fn) fn();
            return;
        }
        raf = requestAnimationFrame(tick);
    }
    function stopTimer() {
        if (raf) cancelAnimationFrame(raf);
        raf = null; timer = null;
    }
    function addTime(ms) {
        if (timer) timer.start += ms;
    }

    /* ---- Round dots ---- */
    function setDots(total, states) {
        const c = $('dots'); c.innerHTML = '';
        for (let i = 0; i < total; i++) {
            const d = document.createElement('div');
            d.className = 'dot' + (states && states[i] ? ' ' + states[i] : '');
            c.appendChild(d);
        }
    }

    /* ---- Lifecycle ---- */
    function open(payload) {
        ended = false;
        applyTheme(payload.theme);
        const game = games[payload.game];
        $('root').classList.remove('hidden');
        $('flash').className = 'hidden';

        const name = game ? game.title : payload.game;
        $('hud-name').textContent = name;
        $('hud-tag').textContent = 'SECURE TASK';
        $('hint').textContent = (game && game.hint) ? game.hint : '';
        $('board').innerHTML = '';
        setDots(0);

        if (!game) { return end(false); }

        const api = {
            board: $('board'),
            cfg: payload,
            startTimer, stopTimer, addTime, setDots,
            setHint: (t) => { $('hint').textContent = t || ''; },
            setTag:  (t) => { $('hud-tag').textContent = t || ''; },
            succeed: () => end(true),
            fail:    () => end(false),
            shake:   () => { $('stage').classList.add('shake');
                             setTimeout(() => $('stage').classList.remove('shake'), 320); },
            rand: (a, b) => a + Math.random() * (b - a),
            randInt: (a, b) => Math.floor(a + Math.random() * (b - a + 1))
        };

        current = game.run(api) || {};
        $('hud-timer').style.visibility = timer ? 'visible' : 'visible';
    }

    function cleanup() {
        stopTimer();
        if (current && typeof current.destroy === 'function') {
            try { current.destroy(); } catch (e) {}
        }
        current = null;
        document.onkeydown = null;
    }

    function end(success) {
        if (ended) return;
        ended = true;
        cleanup();

        const flash = $('flash');
        flash.className = success ? 'win' : 'lose';
        $('flash-text').textContent = success ? 'Success' : 'Failed';

        setTimeout(() => {
            $('root').classList.add('hidden');
            flash.className = 'hidden';
            $('board').innerHTML = '';
            post('result', { success });
        }, 850);
    }

    /* ---- Global cancel key ---- */
    document.addEventListener('keydown', (e) => {
        if (ended || !current) return;
        if (e.key === 'Escape') {
            const allow = current.__allowCancel !== false;
            if (allow) end(false);
        }
    });

    /* ---- Message in from Lua ---- */
    window.addEventListener('message', (ev) => {
        const d = ev.data || {};
        if (d.action === 'open') open(d.payload || {});
    });

    return {
        games,
        register(id, def) { games[id] = def; },
        _internal: { end }
    };
})();
