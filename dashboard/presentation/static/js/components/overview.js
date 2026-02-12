/* Overview / Dashboard page */
const OverviewPage = {
    async render(container) {
        container.innerHTML = '<div class="loading">Loading overview...</div>';

        try {
            const data = await fetch('/api/overview').then(r => r.json());
            container.innerHTML = this._build(data);
        } catch (e) {
            container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">!</div>Error loading overview</div>';
        }
    },

    _build(data) {
        const p = data.project || {};
        const fs = data.features_summary || {};
        const ps = data.plugin_stats || {};

        return `
            <div class="page-header">
                <h2>${p.name || 'AI Development'} Dashboard</h2>
                <p>${p.description || 'Development progress overview'}</p>
            </div>

            <div class="metrics-grid">
                <div class="metric-card">
                    <div class="metric-label">Total Features</div>
                    <div class="metric-value blue">${fs.total || 0}</div>
                    <div class="metric-sub">Plugin v${p.plugin_version || '?'}</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Completed</div>
                    <div class="metric-value green">${fs.completed || 0}</div>
                    <div class="metric-sub">of ${fs.total || 0} features</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">In Progress</div>
                    <div class="metric-value yellow">${fs.in_progress || 0}</div>
                    <div class="metric-sub">${fs.blocked || 0} blocked</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Overall Progress</div>
                    <div class="metric-value purple">${fs.overall_progress_pct || 0}%</div>
                    <div class="metric-sub">across all features</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Agents</div>
                    <div class="metric-value blue">${ps.agents || 0}</div>
                    <div class="metric-sub">specialized agents</div>
                </div>
                <div class="metric-card">
                    <div class="metric-label">Skills + Commands</div>
                    <div class="metric-value green">${(ps.skills || 0) + (ps.commands || 0)}</div>
                    <div class="metric-sub">${ps.skills || 0} skills, ${ps.commands || 0} commands</div>
                </div>
            </div>

            <div class="features-grid">
                ${(data.features || []).map(f => this._featureCard(f)).join('')}
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 16px;">
                <div class="card">
                    <div class="card-header"><h3>Recent Commits</h3></div>
                    <div class="card-body">
                        ${this._commitsList(data.recent_commits || [])}
                    </div>
                </div>
                <div class="card">
                    <div class="card-header"><h3>Recent Sessions</h3></div>
                    <div class="card-body">
                        ${this._sessionsList(data.recent_sessions || [])}
                    </div>
                </div>
            </div>
        `;
    },

    _featureCard(f) {
        const roles = f.roles || {};
        const statusClass = this._statusClass(f.overall_status);

        return `
            <div class="feature-card" onclick="App.navigate('/features/${f.id}')">
                <div class="feature-card-header">
                    <div>
                        <div class="feature-name">${f.name || f.id}</div>
                        <div class="feature-workflow">${f.workflow || 'default'}</div>
                    </div>
                    <span class="badge badge-${statusClass}">${f.overall_status}</span>
                </div>
                <div class="progress-bar-container">
                    <div class="progress-label">
                        <span class="progress-label-name">Overall</span>
                        <span class="progress-label-value">${f.overall_progress_pct}%</span>
                    </div>
                    <div class="progress-bar">
                        <div class="progress-fill ${this._progressColor(f.overall_progress_pct)}"
                             style="width: ${f.overall_progress_pct}%"></div>
                    </div>
                </div>
                <div class="roles-grid">
                    ${['planner','backend','frontend','qa'].map(r => {
                        const role = roles[r];
                        if (!role) return '<div class="role-segment pending"></div>';
                        const cls = this._roleSegmentClass(role.status);
                        return `<div class="role-segment ${cls}" title="${r}: ${role.status} (${role.progress_pct}%)"></div>`;
                    }).join('')}
                </div>
                <div style="display: flex; gap: 16px; margin-top: 12px; font-size: 11px; color: var(--text-muted)">
                    ${['planner','backend','frontend','qa'].map(r => {
                        const role = roles[r];
                        return `<span>${r.charAt(0).toUpperCase() + r.slice(1)}: ${role ? role.progress_pct + '%' : '-'}</span>`;
                    }).join('')}
                </div>
            </div>
        `;
    },

    _commitsList(commits) {
        if (!commits.length) return '<div class="empty-state">No recent commits</div>';
        return commits.map(c => `
            <div style="padding: 8px 0; border-bottom: 1px solid var(--border-light); font-size: 13px;">
                <code style="color: var(--accent-yellow); margin-right: 8px;">${c.short_hash}</code>
                <span>${this._truncate(c.message, 60)}</span>
                <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">
                    ${c.author} - ${this._formatDate(c.date)}
                </div>
            </div>
        `).join('');
    },

    _sessionsList(sessions) {
        if (!sessions.length) return '<div class="empty-state">No sessions found</div>';
        return sessions.map(s => `
            <div style="padding: 8px 0; border-bottom: 1px solid var(--border-light); font-size: 13px;">
                <span style="color: var(--accent-blue); font-weight: 500;">${s.slug || s.session_id.substring(0, 8)}</span>
                <span style="margin-left: 8px; color: var(--text-secondary);">${s.message_count} messages</span>
                <div style="font-size: 11px; color: var(--text-muted); margin-top: 2px;">
                    ${s.model || 'unknown model'} - ${this._formatDate(s.started_at)}
                </div>
            </div>
        `).join('');
    },

    _statusClass(status) {
        if (!status) return 'pending';
        const s = status.toUpperCase();
        if (s === 'COMPLETED' || s === 'APPROVED') return 'completed';
        if (s === 'IN_PROGRESS' || s === 'IN PROGRESS') return 'progress';
        if (s === 'BLOCKED') return 'blocked';
        if (s.includes('WAITING')) return 'waiting';
        return 'pending';
    },

    _roleSegmentClass(status) {
        if (!status) return 'pending';
        const s = status.toUpperCase();
        if (s === 'COMPLETED' || s === 'APPROVED') return 'completed';
        if (s === 'IN_PROGRESS') return 'progress';
        if (s === 'BLOCKED') return 'blocked';
        return 'pending';
    },

    _progressColor(pct) {
        if (pct >= 80) return 'green';
        if (pct >= 40) return 'blue';
        if (pct > 0) return 'yellow';
        return 'blue';
    },

    _truncate(str, len) {
        if (!str) return '';
        return str.length > len ? str.substring(0, len) + '...' : str;
    },

    _formatDate(dateStr) {
        if (!dateStr) return '';
        try {
            const d = new Date(dateStr);
            return d.toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' });
        } catch {
            return dateStr;
        }
    }
};
