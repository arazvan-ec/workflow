#!/usr/bin/env python3
"""Generate a self-contained preview.html with all dashboard data embedded."""
import sys, json, os
sys.path.insert(0, os.path.dirname(__file__))

from infrastructure.config import Settings
from infrastructure.repositories import (
    FeatureRepository, SessionRepository, GitRepository,
    PluginRepository, ConfigRepository
)
from application.services import (
    FeatureService, SessionService, PluginService,
    QualityService, OverviewService
)

def gather_data():
    settings = Settings()
    feature_repo = FeatureRepository(settings)
    session_repo = SessionRepository(settings)
    git_repo = GitRepository(settings)
    plugin_repo = PluginRepository(settings)
    config_repo = ConfigRepository(settings)

    feature_svc = FeatureService(feature_repo)
    session_svc = SessionService(session_repo)
    plugin_svc = PluginService(plugin_repo)
    quality_svc = QualityService(feature_repo)
    overview_svc = OverviewService(feature_svc, session_svc, plugin_repo, git_repo, config_repo)

    data = {
        'overview': overview_svc.get_overview(),
        'features_detail': {},
        'tasks': {},
        'sessions': session_svc.list_sessions(),
        'quality': quality_svc.get_quality_overview(),
        'agents': plugin_svc.get_agents(),
        'skills': plugin_svc.get_skills(),
        'commands': plugin_svc.get_commands(),
        'plugin_info': plugin_svc.get_info(),
        'commits': [
            {'hash':c.hash,'short_hash':c.short_hash,'message':c.message,
             'author':c.author,'date':c.date,'files_changed':c.files_changed,
             'insertions':c.insertions,'deletions':c.deletions,
             'files': [{'path':f.path,'status':f.status,'insertions':f.insertions,'deletions':f.deletions} for f in c.files],
             'diff':c.diff}
            for c in git_repo.get_commits_with_details(limit=30, max_diff_lines=500)
        ],
        'branches': git_repo.get_branches(),
    }

    for f in data['overview']['features']:
        fid = f['id']
        detail = feature_svc.get_feature(fid)
        if detail:
            data['features_detail'][fid] = detail
        data['tasks'][fid] = feature_svc.get_tasks(fid)

    return data


def generate():
    data = gather_data()
    json_str = json.dumps(data, default=str)
    # Escape </ to prevent premature script tag closure in HTML
    json_str = json_str.replace('</', '<\\/')

    html_path = os.path.join(os.path.dirname(__file__), 'preview.html')
    template_path = os.path.join(os.path.dirname(__file__), '_preview_template.html')

    with open(template_path, 'r') as f:
        template = f.read()

    html = template.replace('__DASHBOARD_DATA__', json_str)

    with open(html_path, 'w') as f:
        f.write(html)

    size = os.path.getsize(html_path)
    print(f"Generated {html_path} ({size:,} bytes / {size/1024:.1f} KB)")


if __name__ == '__main__':
    generate()
