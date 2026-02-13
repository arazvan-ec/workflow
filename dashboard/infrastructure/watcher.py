"""File watcher for real-time dashboard updates using watchdog."""
from __future__ import annotations

import asyncio
import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler


class DebouncedHandler(FileSystemEventHandler):
    def __init__(self, callback, debounce_seconds: float = 0.5):
        self._callback = callback
        self._debounce = debounce_seconds
        self._last_event_time: dict[str, float] = {}
        self._loop: asyncio.AbstractEventLoop | None = None

    def set_loop(self, loop: asyncio.AbstractEventLoop):
        self._loop = loop

    def on_modified(self, event):
        if event.is_directory:
            return
        self._handle(event.src_path)

    def on_created(self, event):
        if event.is_directory:
            return
        self._handle(event.src_path)

    def _handle(self, path: str):
        now = time.time()
        last = self._last_event_time.get(path, 0)
        if now - last < self._debounce:
            return
        self._last_event_time[path] = now

        if self._loop and self._callback:
            self._loop.call_soon_threadsafe(
                asyncio.ensure_future,
                self._callback(path),
            )


class FileWatcher:
    def __init__(self, on_change):
        self._on_change = on_change
        self._observer = Observer()
        self._handler = DebouncedHandler(on_change, debounce_seconds=0.5)

    def set_loop(self, loop: asyncio.AbstractEventLoop):
        self._handler.set_loop(loop)

    def add_path(self, path: str | Path):
        path = Path(path)
        if path.exists():
            self._observer.schedule(self._handler, str(path), recursive=True)

    def start(self):
        self._observer.start()

    def stop(self):
        self._observer.stop()
        self._observer.join(timeout=5)
