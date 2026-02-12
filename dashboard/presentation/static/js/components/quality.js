/* Quality metrics page */
const QualityPage = {
    async render(container) {
        container.innerHTML = '<div class="loading">Loading quality metrics...</div>';

        try {
            const data = await fetch('/api/quality').then(r => r.json());
            container.innerHTML = this._build(data);
        } catch (e) {
            container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">!</div>Error loading quality data</div>';
        }
    },

    _build(data) {
        const features = data.features || [];

        if (!features.length) {
            return `
                <div class="page-header"><h2>Quality Metrics</h2><p>Code quality across features</p></div>
                <div class="empty-state"><div class="empty-state-icon">&#10003;</div>No quality data available</div>
            `;
        }

        return `
            <div class="page-header"><h2>Quality Metrics</h2><p>Code quality and coverage across all features</p></div>

            ${features.map(f => this._featureQuality(f)).join('')}
        `;
    },

    _featureQuality(f) {
        const roles = f.roles || {};
        const roleKeys = Object.keys(roles);

        return `
            <div class="card">
                <div class="card-header">
                    <h3>${f.feature_name || f.feature_id}</h3>
                </div>
                <div class="card-body">
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Role</th>
                                    <th>Completion</th>
                                    <th>Coverage (Lines)</th>
                                    <th>Coverage (Branches)</th>
                                    <th>Blockers</th>
                                </tr>
                            </thead>
                            <tbody>
                                ${roleKeys.map(key => {
                                    const r = roles[key];
                                    return `
                                        <tr>
                                            <td style="text-transform: capitalize; font-weight: 500;">${key}</td>
                                            <td>
                                                <div class="progress-bar" style="width: 120px; display: inline-block; vertical-align: middle;">
                                                    <div class="progress-fill ${OverviewPage._progressColor(r.completed_pct)}"
                                                         style="width: ${r.completed_pct}%"></div>
                                                </div>
                                                <span style="margin-left: 8px; font-size: 12px;">${r.completed_pct}%</span>
                                            </td>
                                            <td>${r.coverage_lines && r.coverage_lines !== '-%' ? r.coverage_lines : '<span style="color: var(--text-muted);">-</span>'}</td>
                                            <td>${r.coverage_branches && r.coverage_branches !== '-%' ? r.coverage_branches : '<span style="color: var(--text-muted);">-</span>'}</td>
                                            <td>${r.blockers && r.blockers.length ?
                                                `<span style="color: var(--accent-red);">${r.blockers.length}</span>` :
                                                '<span style="color: var(--accent-green);">0</span>'}</td>
                                        </tr>
                                    `;
                                }).join('')}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        `;
    }
};
