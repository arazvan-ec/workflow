"""AI Development Progress Dashboard - FastAPI Application."""
from __future__ import annotations

import asyncio
import sys
from pathlib import Path
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse

from infrastructure.config import Settings
from infrastructure.repositories import (
    FeatureRepository, SessionRepository, GitRepository,
    PluginRepository, ConfigRepository, SnapshotRepository,
)
from infrastructure.watcher import FileWatcher
from application.services import (
    FeatureService, SessionService, OverviewService,
    PluginService, QualityService,
)
from presentation import api as api_module

# --- Configuration ---
settings = Settings()

# --- Repositories ---
feature_repo = FeatureRepository(settings)
session_repo = SessionRepository(settings)
git_repo = GitRepository(settings)
plugin_repo = PluginRepository(settings)
config_repo = ConfigRepository(settings)
snapshot_repo = SnapshotRepository(settings)

# --- Services ---
feature_service = FeatureService(feature_repo)
session_service = SessionService(session_repo)
quality_service = QualityService(feature_repo)
plugin_service = PluginService(plugin_repo)
overview_service = OverviewService(
    feature_service, session_service, plugin_repo, git_repo, config_repo,
)

# --- Inject into API module ---
api_module.feature_service = feature_service
api_module.session_service = session_service
api_module.overview_service = overview_service
api_module.plugin_service = plugin_service
api_module.quality_service = quality_service
api_module.git_repo = git_repo
api_module.snapshot_repo = snapshot_repo
api_module.config_repo = config_repo


# --- File change handler ---
async def on_file_change(path: str):
    """Handle file changes and broadcast updates via WebSocket."""
    try:
        if "50_state.md" in path:
            # Extract feature_id from path
            parts = Path(path).parts
            try:
                features_idx = parts.index("features")
                feature_id = parts[features_idx + 1]
                feature_repo.invalidate(feature_id)
                data = feature_service.get_feature(feature_id)
                if data:
                    await api_module.ws_manager.broadcast({
                        "type": "feature_update",
                        "feature_id": feature_id,
                        "data": data,
                    })
            except (ValueError, IndexError):
                pass
        elif path.endswith(".jsonl"):
            sessions = session_service.list_sessions()[:3]
            await api_module.ws_manager.broadcast({
                "type": "session_update",
                "data": sessions,
            })
        else:
            # Generic change notification
            await api_module.ws_manager.broadcast({
                "type": "file_changed",
                "path": path,
            })
    except Exception as e:
        print(f"[watcher] Error handling change for {path}: {e}")


# --- File Watcher ---
watcher = FileWatcher(on_change=on_file_change)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Manage startup/shutdown of file watcher."""
    loop = asyncio.get_event_loop()
    watcher.set_loop(loop)
    watcher.add_path(settings.ai_dir)
    if settings.session_logs_dir.exists():
        watcher.add_path(settings.session_logs_dir)
    watcher.start()
    print(f"[dashboard] File watcher started on {settings.ai_dir}")
    yield
    watcher.stop()
    print("[dashboard] File watcher stopped")


# --- FastAPI App ---
app = FastAPI(
    title="AI Development Progress Dashboard",
    version="1.0.0",
    lifespan=lifespan,
)

# API routes
app.include_router(api_module.router, prefix="/api")

# Static files
static_dir = Path(__file__).parent / "presentation" / "static"
app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")


@app.get("/")
async def root():
    return FileResponse(str(static_dir / "index.html"))


# SPA fallback - serve index.html for unmatched routes (except /api and /static)
@app.get("/{path:path}")
async def spa_fallback(path: str):
    if path.startswith("api/") or path.startswith("static/"):
        from fastapi import HTTPException
        raise HTTPException(status_code=404)
    return FileResponse(str(static_dir / "index.html"))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.host,
        port=settings.port,
        log_level="info",
        reload=False,
    )
