/* WebSocket client with auto-reconnection */
const WS = {
    socket: null,
    reconnectDelay: 1000,
    maxDelay: 30000,
    listeners: [],

    connect() {
        const proto = location.protocol === 'https:' ? 'wss:' : 'ws:';
        const url = `${proto}//${location.host}/api/ws`;

        try {
            this.socket = new WebSocket(url);
        } catch (e) {
            this._scheduleReconnect();
            return;
        }

        this.socket.onopen = () => {
            this.reconnectDelay = 1000;
            this._updateStatus('connected');
            this.send({ type: 'request_refresh' });
        };

        this.socket.onmessage = (event) => {
            try {
                const data = JSON.parse(event.data);
                this.listeners.forEach(fn => fn(data));
            } catch (e) {
                console.error('[ws] Parse error:', e);
            }
        };

        this.socket.onclose = () => {
            this._updateStatus('disconnected');
            this._scheduleReconnect();
        };

        this.socket.onerror = () => {
            this._updateStatus('disconnected');
        };
    },

    send(data) {
        if (this.socket && this.socket.readyState === WebSocket.OPEN) {
            this.socket.send(JSON.stringify(data));
        }
    },

    onMessage(fn) {
        this.listeners.push(fn);
    },

    _scheduleReconnect() {
        setTimeout(() => {
            this.reconnectDelay = Math.min(this.reconnectDelay * 1.5, this.maxDelay);
            this.connect();
        }, this.reconnectDelay);
    },

    _updateStatus(status) {
        const dot = document.querySelector('.ws-dot');
        const text = document.querySelector('.ws-text');
        if (!dot || !text) return;

        dot.className = 'ws-dot ' + status;
        text.textContent = status === 'connected' ? 'Live' : 'Reconnecting...';
    }
};
