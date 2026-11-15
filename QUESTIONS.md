# Download manager coding exercise

Imagine a user adds several files to a download queue. They expect files to download in
order, progress to make sense, and the pause, resume, cancel, and retry buttons to work
reliably—even when updates arrive late.

The screen and a local download simulation are already provided. The manager contains
deliberate bugs. Your task is to repair its behavior and add two focused tests.

You have 90 minutes, including a short discussion at the end. You do not need to add real
network requests, file storage, platform plugins, or background services.

## Q1 — Make the download queue work correctly (40 minutes)

With the default limit of three, adding files A, B, C, D, and E should start A, B, and C.
D and E should wait. When a running file finishes or fails, D should start next, followed
by E when another slot becomes available.

Repair the manager so it meets these requirements:

- Never run more downloads than the configured limit, which defaults to three.
- Start waiting files in the order they joined the queue.
- Keep each file's identity stable. Adding an existing ID must not duplicate or restart it.
- Keep downloaded bytes between zero and the file's total size. Progress must not move
  backwards within an attempt, and completion must set downloaded bytes to the total size.
- Calculate overall progress as total downloaded bytes divided by total file bytes across
  all non-cancelled files. Waiting, paused, completed, and failed files still count.
  With no files, overall progress is zero.

Files can be queued, running, paused, completed, failed, or cancelled.

## Q2 — Make the controls and late updates reliable (35 minutes)

A user may interact with one file while other files continue downloading. Each action
should affect only the intended file.

| Action | Expected behavior |
| --- | --- |
| Pause a running file | Stop its subscription, free its slot, and immediately start the oldest eligible waiting file. |
| Resume a paused file | Add it to the back of the queue. |
| Cancel a file | Allow cancellation while queued, running, paused, or failed. Cancellation is permanent and removes the file from scheduling. If it was running, free its slot and immediately start the oldest eligible waiting file. |
| Retry a failed file | Add it to the back of the queue. |

Every time a file starts downloading, including after a resume or retry, it begins a new
attempt. Progress, completion, failure, and stream errors may affect a file only while it
is running and only when they belong to its current attempt.

For example, if a failed download has been retried, a late completion from the earlier
attempt must not mark the retry as completed. Updates arriving after a pause, cancellation,
or failure must also have no effect.

If a stream closes without reporting completion or failure, mark its current running
attempt as failed and make its slot available to the next waiting file. Other files must
continue unaffected.

When the manager is disposed, cancel all subscriptions and ensure it publishes no further
notifications.

## Q3 — Add two focused tests (10 minutes)

Replace the two skipped test placeholders with tests that demonstrate:

1. The concurrency limit is respected, and waiting files start in the correct order as
   slots become available.
2. An update from an earlier attempt cannot overwrite a retry or change a cancelled file.

Tests must be deterministic and use controlled streams. Do not use real time, network
calls, or `Future.delayed`.

## Discussion (5 minutes)

Walk us through your approach, including scheduling complexity and subscription ownership.
Discuss how you would extend the design to persist jobs, resume byte ranges, handle app
termination, and integrate a platform background-download service while keeping those
concerns separate from the manager's state transitions.

These production features are discussion topics; you do not need to implement them.
