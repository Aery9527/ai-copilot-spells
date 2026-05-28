(function() {
  const WS_URL = 'ws://' + window.location.host;
  let ws = null;
  let eventQueue = [];

  function connect() {
    ws = new WebSocket(WS_URL);

    ws.onopen = () => {
      eventQueue.forEach(e => ws.send(JSON.stringify(e)));
      eventQueue = [];
    };

    ws.onmessage = (msg) => {
      const data = JSON.parse(msg.data);
      if (data.type === 'reload') {
        window.location.reload();
      }
    };

    ws.onclose = () => {
      setTimeout(connect, 1000);
    };
  }

  function sendEvent(event) {
    event.timestamp = Date.now();
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(JSON.stringify(event));
    } else {
      eventQueue.push(event);
    }
  }

  // 擷取選擇元素上的點擊事件
  document.addEventListener('click', (e) => {
    const target = e.target.closest('[data-choice]');
    if (!target) return;

    sendEvent({
      type: 'click',
      text: target.textContent.trim(),
      choice: target.dataset.choice,
      id: target.id || null
    });

    // 更新指示器列（延遲執行，讓 toggleSelect 先運行）
    setTimeout(() => {
      const indicator = document.getElementById('indicator-text');
      if (!indicator) return;
      const container = target.closest('.options') || target.closest('.cards');
      const selected = container ? container.querySelectorAll('.selected') : [];
      if (selected.length === 0) {
        indicator.textContent = '點擊上方選項後，返回終端機繼續';
      } else if (selected.length === 1) {
        const label = selected[0].querySelector('h3, .content h3, .card-body h3')?.textContent?.trim() || selected[0].dataset.choice;
        indicator.innerHTML = '<span class="selected-text">已選擇 ' + label + '</span> — 返回終端機繼續';
      } else {
        indicator.innerHTML = '<span class="selected-text">已選擇 ' + selected.length + ' 個</span> — 返回終端機繼續';
      }
    }, 0);
  });

  // Frame UI：選擇追蹤
  window.selectedChoice = null;

  window.toggleSelect = function(el) {
    const container = el.closest('.options') || el.closest('.cards');
    const multi = container && container.dataset.multiselect !== undefined;
    if (container && !multi) {
      container.querySelectorAll('.option, .card').forEach(o => o.classList.remove('selected'));
    }
    if (multi) {
      el.classList.toggle('selected');
    } else {
      el.classList.add('selected');
    }
    window.selectedChoice = el.dataset.choice;
  };

  // 公開 API 供明確使用
  window.brainstorm = {
    send: sendEvent,
    choice: (value, metadata = {}) => sendEvent({ type: 'choice', value, ...metadata })
  };

  connect();
})();
