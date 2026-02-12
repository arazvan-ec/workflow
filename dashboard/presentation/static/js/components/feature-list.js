/* Feature list page */
const FeatureListPage = {
    async render(container) {
        container.innerHTML = '<div class="loading">Loading features...</div>';

        try {
            const features = await fetch('/api/features').then(r => r.json());
            container.innerHTML = this._build(features);
        } catch (e) {
            container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">!</div>Error loading features</div>';
        }
    },

    _build(features) {
        if (!features.length) {
            return `
                <div class="page-header"><h2>Features</h2><p>All project features and their progress</p></div>
                <div class="empty-state"><div class="empty-state-icon">&#9881;</div>No features found</div>
            `;
        }

        return `
            <div class="page-header"><h2>Features</h2><p>${features.length} features tracked</p></div>
            <div class="features-grid">
                ${features.map(f => OverviewPage._featureCard(f)).join('')}
            </div>
        `;
    }
};
