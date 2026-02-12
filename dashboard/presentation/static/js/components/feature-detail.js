/* Feature detail page */
const FeatureDetailPage = {
    async render(container, featureId) {
        container.innerHTML = '<div class="loading">Loading feature...</div>';

        try {
            const [feature, tasks] = await Promise.all([
                fetch(`/api/features/${featureId}`).then(r => r.json()),
                fetch(`/api/features/${featureId}/tasks`).then(r => r.json()),
            ]);
            container.innerHTML = this._build(feature, tasks);
        } catch (e) {
            container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">!</div>Feature not found</div>';
        }
    },

    _build(f, tasks) {
        const statusClass = OverviewPage._statusClass(f.overall_status);

        return `
            <a href="#/features" class="back-link">&larr; Back to Features</a>

            <div class="feature-detail-header">
                <div>
                    <div class="feature-detail-title">${f.name || f.id}</div>
                    <div class="feature-meta">
                        <span class="feature-meta-item">Workflow: <strong>${f.workflow}</strong></span>
                        <span class="feature-meta-item">Created: <strong>${f.created || '-'}</strong></span>
                        <span class="feature-meta-item">Updated: <strong>${f.last_updated || '-'}</strong></span>
                    </div>
                </div>
                <div style="text-align: right;">
                    <span class="badge badge-${statusClass}" style="font-size: 13px; padding: 4px 14px;">${f.overall_status}</span>
                    <div style="font-size: 24px; font-weight: 700; margin-top: 8px; color: var(--accent-blue);">${f.overall_progress_pct}%</div>
                </div>
            </div>

            ${this._overallProgress(f)}
            ${this._rolesDetail(f.roles || {})}
            ${this._phasesSection(f.phases || [])}
            ${this._tasksSection(tasks)}
            ${this._decisionsSection(f.decisions || [])}
            ${this._artifactsSection(f.artifacts || [], f.id)}
            ${this._blockersSection(f.blockers || [])}
        `;
    },

    _overallProgress(f) {
        const roles = f.roles || {};
        return `
            <div class="card" style="margin-bottom: 24px;">
                <div class="card-body">
                    ${['planner','backend','frontend','qa'].map(r => {
                        const role = roles[r];
                        if (!role) return '';
                        const color = OverviewPage._progressColor(role.progress_pct);
                        return `
                            <div class="progress-bar-container">
                                <div class="progress-label">
                                    <span class="progress-label-name" style="text-transform: capitalize;">${r}</span>
                                    <span class="progress-label-value">${role.progress_pct}% (${role.checkpoints_done}/${role.checkpoints_total})</span>
                                </div>
                                <div class="progress-bar">
                                    <div class="progress-fill ${color}" style="width: ${role.progress_pct}%"></div>
                                </div>
                            </div>
                        `;
                    }).join('')}
                </div>
            </div>
        `;
    },

    _rolesDetail(roles) {
        const roleKeys = ['planner', 'backend', 'frontend', 'qa'];

        return `
            <h3 style="margin-bottom: 16px; font-size: 16px;">Role Progress</h3>
            <div class="roles-detail-grid">
                ${roleKeys.map(key => {
                    const r = roles[key];
                    if (!r) return '';
                    return this._roleCard(r);
                }).join('')}
            </div>
        `;
    },

    _roleCard(r) {
        const statusClass = OverviewPage._statusClass(r.status);
        const circumference = 2 * Math.PI * 22;
        const dashoffset = circumference - (r.progress_pct / 100) * circumference;
        const strokeColor = r.status === 'COMPLETED' ? 'var(--accent-green)' :
                           r.status === 'BLOCKED' ? 'var(--accent-red)' : 'var(--accent-blue)';

        return `
            <div class="role-card">
                <div class="role-card-header">
                    <div>
                        <div class="role-title">${r.role}</div>
                        <span class="badge badge-${statusClass}" style="margin-top: 4px;">${r.status}</span>
                    </div>
                    <div class="circle-progress">
                        <svg viewBox="0 0 48 48">
                            <circle class="track" cx="24" cy="24" r="22"/>
                            <circle class="fill" cx="24" cy="24" r="22"
                                stroke="${strokeColor}"
                                stroke-dasharray="${circumference}"
                                stroke-dashoffset="${dashoffset}"/>
                        </svg>
                        <div class="value">${Math.round(r.progress_pct)}%</div>
                    </div>
                </div>

                ${r.current_task ? `<div style="font-size: 12px; color: var(--accent-yellow); margin-bottom: 8px;">Current: ${r.current_task}</div>` : ''}

                ${r.depends_on && r.depends_on.length ? `
                    <div style="font-size: 11px; color: var(--text-muted); margin-bottom: 8px;">
                        Depends on: ${r.depends_on.join(', ')}
                    </div>
                ` : ''}

                ${r.notes && r.notes.length ? `
                    <div style="font-size: 12px; color: var(--text-secondary); margin-bottom: 8px;">
                        ${r.notes.map(n => `<div style="margin-bottom: 2px;">- ${n}</div>`).join('')}
                    </div>
                ` : ''}

                ${r.completed_tasks && r.completed_tasks.length ? `
                    <div style="font-size: 11px; color: var(--text-muted); margin-top: 8px;">
                        ${r.completed_tasks.length} tasks completed
                    </div>
                ` : ''}

                ${r.coverage_lines && r.coverage_lines !== '-%' ? `
                    <div style="font-size: 11px; color: var(--text-muted); margin-top: 4px;">
                        Coverage: Lines ${r.coverage_lines}, Branches ${r.coverage_branches || '-'}
                    </div>
                ` : ''}

                ${r.blockers && r.blockers.length ? `
                    <div style="font-size: 12px; color: var(--accent-red); margin-top: 8px;">
                        Blockers: ${r.blockers.join('; ')}
                    </div>
                ` : ''}
            </div>
        `;
    },

    _phasesSection(phases) {
        if (!phases.length) return '';
        return `
            <div class="card">
                <div class="card-header"><h3>Phase Progress</h3></div>
                <div class="card-body">
                    <div class="phases-row">
                        ${phases.map(p => {
                            const cls = p.status.toUpperCase().includes('COMPLETED') ? 'completed' :
                                       p.status.toUpperCase().includes('PROGRESS') ? 'in_progress' : 'pending';
                            return `<div class="phase-chip ${cls}">${p.name} (${p.progress_pct}%)</div>`;
                        }).join('')}
                    </div>
                    <div class="table-container">
                        <table>
                            <thead><tr><th>Phase</th><th>Status</th><th>Tasks</th><th>Progress</th></tr></thead>
                            <tbody>
                                ${phases.map(p => `
                                    <tr>
                                        <td>${p.name}</td>
                                        <td><span class="badge badge-${OverviewPage._statusClass(p.status)}">${p.status}</span></td>
                                        <td>${p.tasks_done}/${p.tasks_total}</td>
                                        <td>${p.progress_pct}%</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    _tasksSection(tasks) {
        if (!tasks.length) return '';
        const done = tasks.filter(t => t.done).length;
        return `
            <div class="card">
                <div class="card-header">
                    <h3>Tasks (${done}/${tasks.length} done)</h3>
                </div>
                <div class="card-body">
                    <div class="table-container">
                        <table>
                            <thead><tr><th>ID</th><th>Title</th><th>Status</th><th>Priority</th></tr></thead>
                            <tbody>
                                ${tasks.map(t => `
                                    <tr>
                                        <td><code>${t.id}</code></td>
                                        <td>${t.title}</td>
                                        <td>${t.done ?
                                            '<span class="badge badge-completed">Done</span>' :
                                            '<span class="badge badge-pending">Pending</span>'}</td>
                                        <td>${t.priority || '-'}</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    _decisionsSection(decisions) {
        if (!decisions.length) return '';
        return `
            <div class="card">
                <div class="card-header"><h3>Decisions</h3></div>
                <div class="card-body">
                    <div class="table-container">
                        <table class="decisions-table">
                            <thead><tr><th>Date</th><th>Decision</th><th>Rationale</th></tr></thead>
                            <tbody>
                                ${decisions.map(d => `
                                    <tr>
                                        <td>${d.date}</td>
                                        <td>${d.decision}</td>
                                        <td style="color: var(--text-secondary)">${d.rationale}</td>
                                    </tr>
                                `).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    },

    _artifactsSection(artifacts, featureId) {
        if (!artifacts.length) return '';
        return `
            <div class="card">
                <div class="card-header"><h3>Artifacts (${artifacts.length})</h3></div>
                <div class="card-body">
                    <ul class="artifact-list">
                        ${artifacts.map(a => `
                            <li class="artifact-item" title="${a}">${a}</li>
                        `).join('')}
                    </ul>
                </div>
            </div>
        `;
    },

    _blockersSection(blockers) {
        if (!blockers.length) return '';
        return `
            <div class="card" style="border-color: var(--accent-red);">
                <div class="card-header"><h3 style="color: var(--accent-red);">Blockers</h3></div>
                <div class="card-body">
                    ${blockers.map(b => `<div style="color: var(--accent-red); margin-bottom: 4px;">${b}</div>`).join('')}
                </div>
            </div>
        `;
    }
};
