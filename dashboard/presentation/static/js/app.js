/* Main SPA application - router and lifecycle */
const App = {
    currentPage: null,

    init() {
        // Connect WebSocket
        WS.connect();
        WS.onMessage(data => this._handleWsMessage(data));

        // Handle navigation
        window.addEventListener('hashchange', () => this._route());

        // Initial route
        this._route();

        // Load plugin version
        this._loadVersion();
    },

    navigate(path) {
        window.location.hash = path;
    },

    async _route() {
        const hash = window.location.hash.replace('#', '') || '/';
        const container = document.getElementById('content');

        // Update active nav link
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
            const page = link.dataset.page;
            if (
                (page === 'overview' && hash === '/') ||
                (page === 'features' && hash.startsWith('/features')) ||
                (page === 'sessions' && hash === '/sessions') ||
                (page === 'quality' && hash === '/quality') ||
                (page === 'plugin' && hash === '/plugin') ||
                (page === 'git' && hash === '/git')
            ) {
                link.classList.add('active');
            }
        });

        // Route to page
        if (hash === '/' || hash === '') {
            this.currentPage = 'overview';
            await OverviewPage.render(container);
        } else if (hash === '/features') {
            this.currentPage = 'features';
            await FeatureListPage.render(container);
        } else if (hash.startsWith('/features/')) {
            this.currentPage = 'feature-detail';
            const featureId = hash.replace('/features/', '');
            await FeatureDetailPage.render(container, featureId);
        } else if (hash === '/sessions') {
            this.currentPage = 'sessions';
            await SessionsPage.render(container);
        } else if (hash === '/quality') {
            this.currentPage = 'quality';
            await QualityPage.render(container);
        } else if (hash === '/plugin') {
            this.currentPage = 'plugin';
            await PluginCatalogPage.render(container);
        } else if (hash === '/git') {
            this.currentPage = 'git';
            await GitTimelinePage.render(container);
        } else {
            container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">?</div>Page not found</div>';
        }
    },

    _handleWsMessage(data) {
        if (data.type === 'feature_update') {
            // If we're on overview or features page, refresh
            if (this.currentPage === 'overview' || this.currentPage === 'features') {
                this._route();
            }
            // If we're on the specific feature detail page
            if (this.currentPage === 'feature-detail') {
                const hash = window.location.hash.replace('#', '');
                if (hash.includes(data.feature_id)) {
                    this._route();
                }
            }
        } else if (data.type === 'session_update') {
            if (this.currentPage === 'sessions' || this.currentPage === 'overview') {
                this._route();
            }
        } else if (data.type === 'full_refresh') {
            this._route();
        }
    },

    async _loadVersion() {
        try {
            const info = await fetch('/api/plugin').then(r => r.json());
            const el = document.getElementById('plugin-version');
            if (el) el.textContent = `v${info.version || '?'}`;
        } catch {}
    }
};

// Start the application
document.addEventListener('DOMContentLoaded', () => App.init());
