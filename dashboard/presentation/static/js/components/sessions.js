/* Sessions page */
const SessionsPage = {
    async render(container) {
        container.innerHTML = '<div class="loading">Loading sessions...</div>';

        try {
            const sessions = await fetch('/api/sessions').then(r => r.json());
            container.innerHTML = this._build(sessions);
        } catch (e) {
            container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">!</div>Error loading sessions</div>';
        }
    },

    _build(sessions) {
        if (!sessions.length) {
            return `
                <div class="page-header"><h2>Sessions</h2><p>Claude Code session history</p></div>
                <div class="empty-state"><div class="empty-state-icon">&#9201;</div>No sessions found</div>
            `;
        }

        const totalMessages = sessions.reduce((sum, s) => sum + s.message_count, 0);
        const totalTokensIn = sessions.reduce((sum, s) => sum + (s.total_input_tokens || 0), 0);
        const totalTokensOut = sessions.reduce((sum, s) => sum + (s.total_output_tokens || 0), 0);

        return `
            <div class="page-header"><h2>Sessions</h2><p>${sessions.length} sessions tracked</p></div>

            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-label">Total Sessions</div>
                    <div class="metric-value blue">${sessions.length}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Total Messages</div>
                    <div class="metric-value green">${totalMessages.toLocaleString()}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Input Tokens</div>
                    <div class="metric-value yellow">${this._formatTokens(totalTokensIn)}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Output Tokens</div>
                    <div class="metric-value purple">${this._formatTokens(totalTokensOut)}</div>
                </div>
            </div>

            ${sessions.map(s => this._sessionCard(s)).join('')}
        `;
    },

    _sessionCard(s) {
        const maxToolCount = s.tool_calls.length ? Math.max(...s.tool_calls.map(t => t.count)) : 1;

        return `
            <div class="session-card">
                <div class="session-header">
                    <div>
                        <div class="session-slug">${s.slug || s.session_id.substring(0, 12)}</div>
                        <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">
                            ID: ${s.session_id.substring(0, 8)}...
                        </div>
                    </div>
                    <div class="session-date">${this._formatDate(s.started_at)}</div>
                </div>
                <div class="session-stats">
                    <div class="session-stat"><strong>${s.message_count}</strong> messages</div>
                    <div class="session-stat"><strong>${s.user_message_count}</strong> user</div>
                    <div class="session-stat"><strong>${s.assistant_message_count}</strong> assistant</div>
                    <div class="session-stat"><strong>${this._formatDuration(s.duration_seconds)}</strong> duration</div>
                    ${s.model ? `<div class="session-stat"><strong>${s.model}</strong></div>` : ''}
                    ${s.git_branch ? `<div class="session-stat">Branch: <strong>${s.git_branch}</strong></div>` : ''}
                    ${s.permission_mode ? `<div class="session-stat">Mode: <strong>${s.permission_mode}</strong></div>` : ''}
                </div>
                ${s.total_input_tokens || s.total_output_tokens ? `
                    <div style="margin-top: 8px; font-size: 12px; color: var(--text-muted);">
                        Tokens: ${this._formatTokens(s.total_input_tokens)} in / ${this._formatTokens(s.total_output_tokens)} out
                    </div>
                ` : ''}
                ${s.tool_calls.length ? `
                    <div class="tool-bars">
                        ${s.tool_calls.slice(0, 8).map(tc => `
                            <div class="tool-bar-row">
                                <div class="tool-bar-name" title="${tc.tool}">${tc.tool}</div>
                                <div class="tool-bar-track">
                                    <div class="tool-bar-fill" style="width: ${(tc.count / maxToolCount) * 100}%"></div>
                                </div>
                                <div class="tool-bar-count">${tc.count}</div>
                            </div>
                        `).join('')}
                    </div>
                ` : ''}
            </div>
        `;
    },

    _formatDate(dateStr) {
        if (!dateStr) return '';
        try {
            const d = new Date(dateStr);
            return d.toLocaleDateString('es-ES', {
                day: '2-digit', month: 'short', year: 'numeric',
                hour: '2-digit', minute: '2-digit'
            });
        } catch { return dateStr; }
    },

    _formatDuration(seconds) {
        if (!seconds) return '-';
        if (seconds < 60) return `${seconds}s`;
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        if (m < 60) return `${m}m ${s}s`;
        const h = Math.floor(m / 60);
        return `${h}h ${m % 60}m`;
    },

    _formatTokens(n) {
        if (!n) return '0';
        if (n >= 1000000) return (n / 1000000).toFixed(1) + 'M';
        if (n >= 1000) return (n / 1000).toFixed(1) + 'K';
        return n.toString();
    }
};
