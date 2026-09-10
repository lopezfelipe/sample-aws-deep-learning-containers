# WhisperX on SageMaker

Deploy the **WhisperX** Deep Learning Container to an Amazon SageMaker real-time
endpoint and transcribe multi-speaker audio into a color-coded, speaker-labeled
transcript with word-level timestamps.

The included notebook uses public-domain [Apollo 11 Moon-landing audio](https://commons.wikimedia.org/wiki/File:Pouso_da_Apollo_11_na_Lua.ogg)
from Wikimedia Commons as its demo clip.

## What it shows

1. **Batched transcription** — WhisperX runs the `large-v2` model with batched
   inference, transcribing far faster than the audio plays.
2. **Word-level timestamps** — wav2vec2 forced alignment gives every word a
   precise start/end time, not just per-segment timing.
3. **Speaker diarization** — each line is labeled `SPEAKER_00`, `SPEAKER_01`, …
   so you can see who spoke when.

The notebook also emits broadcast-ready **SRT captions**.

## Files

- `whisperx_sagemaker_demo.ipynb` — self-contained notebook: deploy the endpoint,
  download and transcode the demo audio, transcribe, render the transcript, and
  tear down. Deploy and invoke calls use `boto3` (`sagemaker`,
  `sagemaker-runtime`); the execution role is resolved via the SageMaker Python
  SDK's `get_execution_role()` when running inside Studio, falling back to
  STS/IAM otherwise.

## Prerequisites

- A **SageMaker Studio** notebook (or any environment with `boto3`) whose
  execution role can `create_model` / `create_endpoint`.
- **Outbound internet** — the notebook downloads the demo clip from Wikimedia
  Commons and pip-installs `imageio-ffmpeg` if `ffmpeg` is not on `PATH`.
- **GPU service quota** for the endpoint instance type (`ml.g4dn.xlarge` by
  default).
- The **WhisperX DLC image URI**. WhisperX DLC images are published to the AWS
  Deep Learning Containers ECR account, e.g.:
  ```
  763104351884.dkr.ecr.us-west-2.amazonaws.com/whisperx:3.8.6-cu128-amzn2023-sagemaker
  ```
  See the [available DLC images](https://github.com/aws/deep-learning-containers/blob/master/available_images.md)
  for the current tag and region.

## Quick start

1. Open `whisperx_sagemaker_demo.ipynb` in SageMaker Studio.
2. In the **CONFIG** cell, set `IMAGE_URI` to the WhisperX DLC image for your
   region. If you are not running inside Studio, also set `ROLE_ARN` to a
   SageMaker execution role ARN.
3. Run the deploy, audio, and warm-up cells, then the transcription and render
   cells to see the color-coded transcript and SRT output.
4. **Run the final teardown cell** to delete the endpoint when you are done.

## Important notes

### The `InferenceAmiVersion` pin is required

The endpoint config sets:

```python
"InferenceAmiVersion": "al2-ami-sagemaker-inference-gpu-3-1"   # CUDA 12 / driver 550
```

Without this pin the GPU endpoint fails to start with a zero-log
`CannotStartContainerError`. Do not remove or change it.

### Warm up before timing a request

The **first** invocation downloads the multi-GB `large-v2` weights and the
wav2vec2 aligner, which can exceed the 60-second real-time invocation cap. The
notebook's `invoke()` helper retries automatically; running the warm-up cell
first avoids a cold-start timeout on the request you care about.

Full-clip transcription + alignment + diarization can also approach the 60-second
cap on `ml.g4dn.xlarge`. Trim the clip with the `APOLLO_START_SEC` /
`APOLLO_DUR_SEC` knobs, or use `INSTANCE_TYPE = "ml.g5.xlarge"` (A10G) for more
headroom.

### Cost / teardown

A GPU real-time endpoint **bills continuously until it is deleted.** The final
cell deletes the endpoint, endpoint config, and model (each best-effort).
Endpoint names use a random suffix, so re-running the CONFIG cell always produces
a fresh, non-colliding name.
