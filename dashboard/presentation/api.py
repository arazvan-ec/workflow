"""REST API endpoints and WebSocket handler."""
from __future__ import annotations

import asyncio
import json
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, HTTPException
from application.services import (
    FeatureService, SessionService, OverviewService,
    PluginService, QualityService,
)
from infrastructure.repositories import GitRepository, SnapshotRepository, ConfigRepository
from dataclasses import asdict

router = APIRouter()

# These get injected at startup from main.py
feature_service: FeatureService = None  # type: ignore
session_service: SessionService = None  # type: ignore
overview_service: OverviewService = None  # type: ignore
plugin_service: PluginService = None  # type: ignore
quality_service: QualityService = None  # type: ignore
git_repo: GitRepository = None  # type: ignore
snapshot_repo: SnapshotRepository = None  # type: ignore
config_repo: ConfigRepository = None  # type: ignore


# --- WebSocket Manager ---
class WebSocketManager:
    def __init__(self):
        self._connections: list[WebSocket] = []

    async def connect(self, ws: WebSocket):
        await ws.accept()
        self._connections.append(ws)

    def disconnect(self, ws: WebSocket):
        if ws in self._connections:
            self._connections.remove(ws)

    async def broadcast(self, data: dict):
        dead = []
        for ws in self._connections:
            try:
                await ws.send_json(data)
            except Exception:
                dead.append(ws)
        for ws in dead:
            self._connections.remove(ws)


ws_manager = WebSocketManager()


# --- Overview ---
@router.get("/overview")
async def get_overview():
    return overview_service.get_overview()


# --- Features ---
@router.get("/features")
async def list_features():
    return feature_service.list_features()


@router.get("/features/{feature_id}")
async def get_feature(feature_id: str):
    result = feature_service.get_feature(feature_id)
    if not result:
        raise HTTPException(status_code=404, detail="Feature not found")
    return result


@router.get("/features/{feature_id}/tasks")
async def get_feature_tasks(feature_id: str):
    return feature_service.get_tasks(feature_id)


@router.get("/features/{feature_id}/artifacts")
async def get_feature_artifacts(feature_id: str):
    return feature_service.repo.get_artifact_list(feature_id)


@router.get("/features/{feature_id}/artifact/{filename}")
async def get_artifact_content(feature_id: str, filename: str):
    content = feature_service.repo.get_artifact_content(feature_id, filename)
    if content is None:
        raise HTTPException(status_code=404, detail="Artifact not found")
    return {"filename": filename, "content": content}


# --- Sessions ---
@router.get("/sessions")
async def list_sessions():
    return session_service.list_sessions()


@router.get("/sessions/{session_id}")
async def get_session(session_id: str):
    result = session_service.get_session(session_id)
    if not result:
        raise HTTPException(status_code=404, detail="Session not found")
    return result


# --- Quality ---
@router.get("/quality")
async def get_quality():
    return quality_service.get_quality_overview()


# --- Git ---
@router.get("/git/commits")
async def get_commits(feature: str | None = None, limit: int = 50):
    from domain.entities import Commit
    commits = git_repo.get_commits(limit=limit, feature=feature)
    return [asdict(c) for c in commits]


@router.get("/git/branches")
async def get_branches():
    return git_repo.get_branches()


# --- Plugin ---
@router.get("/plugin")
async def get_plugin_info():
    return plugin_service.get_info()


@router.get("/plugin/agents")
async def get_agents():
    return plugin_service.get_agents()


@router.get("/plugin/skills")
async def get_skills():
    return plugin_service.get_skills()


@router.get("/plugin/commands")
async def get_commands():
    return plugin_service.get_commands()


# --- Config ---
@router.get("/config")
async def get_config():
    cfg = config_repo.get_config()
    return asdict(cfg)


# --- Snapshots ---
@router.get("/snapshots")
async def get_snapshots():
    snaps = snapshot_repo.list_snapshots()
    return [asdict(s) for s in snaps]


# --- WebSocket ---
@router.websocket("/ws")
async def websocket_endpoint(ws: WebSocket):
    await ws_manager.connect(ws)
    try:
        while True:
            data = await ws.receive_text()
            try:
                msg = json.loads(data)
                if msg.get("type") == "request_refresh":
                    overview = overview_service.get_overview()
                    await ws.send_json({"type": "full_refresh", "data": overview})
            except json.JSONDecodeError:
                pass
    except WebSocketDisconnect:
        ws_manager.disconnect(ws)
