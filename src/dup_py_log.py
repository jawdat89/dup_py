#!/usr/bin/python3

####################################################################################
#
#  Copyright (c) 2022-2026 Piotr Jochymek
#
#  MIT License
#
####################################################################################

"""Dup_py logging: loguru file/console sinks with stdlib logging bridge for core/engine."""

from __future__ import annotations

import logging
import sys
from pathlib import Path

from loguru import logger


class _InterceptHandler(logging.Handler):
    """Route logging.getLogger() records into loguru."""

    def emit(self, record: logging.LogRecord) -> None:
        try:
            level = logger.level(record.levelname).name
        except ValueError:
            level = record.levelno

        frame, depth = logging.currentframe(), 2
        while frame and frame.f_code.co_filename == logging.__file__:
            frame = frame.f_back
            depth += 1

        logger.opt(depth=depth, exception=record.exc_info).log(level, record.getMessage())


def setup_logging(
    log_file: str | Path,
    *,
    debug: bool = False,
    launcher: str | None = None,
) -> None:
    log_path = Path(log_file)
    log_path.parent.mkdir(parents=True, exist_ok=True)

    level = "DEBUG" if debug else "INFO"

    logger.remove()

    logger.add(
        sys.stderr,
        level=level,
        format=(
            "<green>{time:HH:mm:ss}</green> | <level>{level:8}</level> | "
            "<cyan>{name}</cyan>:<cyan>{function}</cyan> - <level>{message}</level>"
        ),
        colorize=True,
    )

    logger.add(
        str(log_path),
        level=level,
        format=(
            "{time:YYYY-MM-DD HH:mm:ss.SSS} | {level:8} | "
            "{name}:{function}:{line} - {message}"
        ),
        rotation="10 MB",
        retention=10,
        encoding="utf-8",
        enqueue=True,
    )

    logging.root.handlers = [_InterceptHandler()]
    logging.root.setLevel(logging.DEBUG if debug else logging.INFO)

    logger.info("Logging initialized (loguru + stdlib bridge)")
    logger.info("Log file: {}", log_path.resolve())
    if launcher:
        logger.info("Launcher: {}", launcher)
    logger.info(
        "Python {} ({})",
        sys.version.split()[0],
        "64-bit" if sys.maxsize > 2**32 else "32-bit",
    )
    logger.debug("Executable: {}", sys.executable)


def get_logger(component: str):
    return logger.bind(component=component)


def require_64bit_python() -> None:
    """Exit if Python is not 64-bit (needed for large files and caches on Windows)."""
    if sys.maxsize <= 2**32:
        msg = (
            'Dup_py requires 64-bit Python. '
            'On Windows use run-dup_py64.bat or: py -3-64 src\\dup_py.py ...'
        )
        print(msg, file=sys.stderr)
        sys.exit(1)
