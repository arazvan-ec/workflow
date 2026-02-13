/* Plugin catalog page - agents, skills, commands */
const PluginCatalogPage = {
    _currentTab: 'agents',

    async render(container) {
        container.innerHTML = '<div class="loading">Loading plugin catalog...</div>';

        try {
            const [agents, skills, commands, info] = await Promise.all([
                fetch('/api/plugin/agents').then(r => r.json()),
                fetch('/api/plugin/skills').then(r => r.json()),
                fetch('/api/plugin/commands').then(r => r.json()),
                fetch('/api/plugin').then(r => r.json()),
            ]);
            this._data = { agents, skills, commands, info };
            container.innerHTML = this._build();
            this._bindTabs(container);
        } catch (e) {
            container.innerHTML = '<div class="empty-state"><div class="empty-state-icon">!</div>Error loading plugin data</div>';
        }
    },

    _build() {
        const d = this._data;
        return `
            <div class="page-header">
                <h2>Plugin Catalog</h2>
                <p>${d.info.name || 'multi-agent-workflow'} v${d.info.version || '?'} - ${d.agents.length} agents, ${d.skills.length} skills, ${d.commands.length} commands</p>
            </div>

            <div class="catalog-tabs">
                <button class="catalog-tab active" data-tab="agents">Agents (${d.agents.length})</button>
                <button class="catalog-tab" data-tab="skills">Skills (${d.skills.length})</button>
                <button class="catalog-tab" data-tab="commands">Commands (${d.commands.length})</button>
            </div>

            <div id="catalog-content">
                ${this._agentsGrid(d.agents)}
            </div>
        `;
    },

    _bindTabs(container) {
        container.querySelectorAll('.catalog-tab').forEach(tab => {
            tab.addEventListener('click', () => {
                container.querySelectorAll('.catalog-tab').forEach(t => t.classList.remove('active'));
                tab.classList.add('active');

                const type = tab.dataset.tab;
                const content = container.querySelector('#catalog-content');
                if (type === 'agents') content.innerHTML = this._agentsGrid(this._data.agents);
                else if (type === 'skills') content.innerHTML = this._skillsGrid(this._data.skills);
                else content.innerHTML = this._commandsGrid(this._data.commands);
            });
        });
    },

    _agentsGrid(agents) {
        // Group by category
        const groups = {};
        agents.forEach(a => {
            const cat = a.category || 'other';
            if (!groups[cat]) groups[cat] = [];
            groups[cat].push(a);
        });

        return Object.entries(groups).map(([cat, items]) => `
            <h4 style="margin: 16px 0 8px; font-size: 13px; text-transform: uppercase; color: var(--text-muted); letter-spacing: 0.5px;">${cat}</h4>
            <div class="catalog-grid">
                ${items.map(a => `
                    <div class="catalog-item">
                        <div class="catalog-item-name">${a.name}</div>
                        <div class="catalog-item-category">${a.category}</div>
                        <div class="catalog-item-desc">${a.description || 'No description'}</div>
                    </div>
                `).join('')}
            </div>
        `).join('');
    },

    _skillsGrid(skills) {
        return `
            <div class="catalog-grid" style="margin-top: 16px;">
                ${skills.map(s => `
                    <div class="catalog-item">
                        <div class="catalog-item-name">${s.name}</div>
                        <div class="catalog-item-desc">${s.description || 'No description'}</div>
                    </div>
                `).join('')}
            </div>
        `;
    },

    _commandsGrid(commands) {
        return `
            <div class="catalog-grid" style="margin-top: 16px;">
                ${commands.map(c => `
                    <div class="catalog-item">
                        <div class="catalog-item-name">/workflows:${c.name}</div>
                        ${c.argument_hint ? `<div class="catalog-item-category">${c.argument_hint}</div>` : ''}
                        <div class="catalog-item-desc">${c.description || 'No description'}</div>
                    </div>
                `).join('')}
            </div>
        `;
    }
};
