# open-text-embeddings

重构`Dockerfile`和新增`docker-compose.yml`以支持一键部署

现在可以通过运行`docker-compose up`来构建并启动使用`lier007/xiaobu-embedding-v2`模型的服务。

## 快速启动：

<details>
  <summary>启动命令</summary>

  ```bash
  docker run -d -p 8000:8000 ghcr.io/cr-zhichen/cr-zhichen/open-text-embeddings:latest
  ```

</details>

<details>
  <summary>docker-compose.yml</summary>

  ```yml
  version: '3.8'

  services:
     embedding-server:
        image: ghcr.io/cr-zhichen/cr-zhichen/open-text-embeddings:latest
        ports:
           - "8000:8000"
  ```

</details>


--------

[![PyPI](https://img.shields.io/pypi/v/open-text-embeddings)](https://pypi.org/project/open-text-embeddings/)
[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1wfgfkt6xk3meSF5jWHDMqo6mL0ZvPw2f?usp=sharing)
[![Publish Python Package](https://github.com/limcheekin/open-text-embeddings/actions/workflows/publish.yml/badge.svg)](https://github.com/limcheekin/open-text-embeddings/actions/workflows/publish.yml)

Many open source projects support the compatibility of the `completions` and the `chat/completions` endpoints of the OpenAI API, but do not support the `embeddings` endpoint.

The goal of this project is to create an OpenAI API-compatible version of the `embeddings` endpoint, which serves open source sentence-transformers models and other models supported by the LangChain's [HuggingFaceEmbeddings](https://api.python.langchain.com/en/latest/embeddings/langchain.embeddings.huggingface.HuggingFaceEmbeddings.html), HuggingFaceInstructEmbeddings and HuggingFaceBgeEmbeddings class.

## ℹ️ Supported Text Embeddings Models

Below is a compilation of open-source models that are tested via the `embeddings` endpoint:

- [BAAI/bge-large-en](https://huggingface.co/BAAI/bge-large-en)
- [intfloat/e5-large-v2](https://huggingface.co/intfloat/e5-large-v2)
- [sentence-transformers/all-MiniLM-L6-v2](https://huggingface.co/sentence-transformers/all-MiniLM-L6-v2)
- [sentence-transformers/all-mpnet-base-v2](https://huggingface.co/sentence-transformers/all-mpnet-base-v2)
- [universal-sentence-encoder-large/5](https://tfhub.dev/google/universal-sentence-encoder-large/5) (Please refer to the `universal_sentence_encoder` branch for more details)

The models mentioned above have undergone testing and verification. It is worth noting that all sentence-transformers models are expected to perform seamlessly with the endpoint.

It may not be immediately apparent that utilizing the `BAAI/bge-*` and `intfloat/e5-*` series of models with the `embeddings` endpoint can yield different embeddings for the same `input` value, depending on how it is sent to the `embeddings` endpoint. Consider the following examples:

**Example 1:**

```json
{
  "input": "The food was delicious and the waiter..."
}
```

**Example 2:**

```json
{
  "input": ["The food was delicious and the waiter..."]
}
```

This discrepancy arises because the `BAAI/bge-*` and `intfloat/e5-*` series of models require the addition of specific prefix text to the `input` value before creating embeddings to achieve optimal performance. In the first example, where the `input` is of type `str`, it is assumed that the embeddings will be used for queries. Conversely, in the second example, where the `input` is of type `List[str]`, it is assumed that you will store the embeddings in a vector database. Adhering to these guidelines is essential to ensure the intended functionality and optimal performance of the models.

## 🔍 Demo

Try out open-text-embeddings in your browser:

[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/drive/1wfgfkt6xk3meSF5jWHDMqo6mL0ZvPw2f?usp=sharing)

## 🖥️ On-Premise Deployment

### Standalone FastAPI Server

To run the embeddings endpoint locally as a standalone FastAPI server, follow these steps:

1. Install the dependencies by executing the following commands:

   ```bash
   pip install --no-cache-dir open-text-embeddings[server]
   ```

2. Download the desired model using the following command, for example `intfloat/e5-large-v2`:

   ```bash
   ./download.sh intfloat/e5-large-v2
   ```

3. Run the server with the desired model using the following command which normalize embeddings is enabled by default:

   ```bash
   MODEL=intfloat/e5-large-v2 python -m open.text.embeddings.server
   ```

   Set the `NORMALIZE_EMBEDDINGS` to `0` or `False` if the model doesn't support normalize embeddings, for example:

   ```bash
   MODEL=intfloat/e5-large-v2 NORMALIZE_EMBEDDINGS=0 python -m open.text.embeddings.server
   ```

   If a GPU is detected in the runtime environment, the server will automatically execute using the `cuba` mode. However, you have the flexibility to specify the `DEVICE` environment variable to choose between `cpu` and `cuba`. Here's an example of how to run the server with your desired configuration:

   ```bash
   MODEL=intfloat/e5-large-v2 DEVICE=cpu python -m open.text.embeddings.server
   ```

   This setup allows you to seamlessly switch between CPU and GPU modes, giving you control over the server's performance based on your specific requirements.

   You can enabled verbose logging by setting the `VERBOSE` to `1`, for example:

   ```bash
   MODEL=intfloat/e5-large-v2 VERBOSE=1 python -m open.text.embeddings.server
   ```

4. You will see the following text from your console once the server has started:

   ```bash
   INFO:     Started server process [19705]
   INFO:     Waiting for application startup.
   INFO:     Application startup complete.
   INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
   ```

## ☁️ Cloud Deployment
To deploy the embeddings endpoint to the cloud platform using GitHub Actions, [fork](https://github.com/limcheekin/open-text-embeddings/fork) the repo first, then follow these steps for:


### AWS Lambda Function

1. Add your AWS credentials (`AWS_KEY` and `AWS_SECRET`) to the repository secrets. You can do this by navigating to [https://github.com/your-username/open-text-embeddings/settings/secrets/actions]().

2. Manually trigger the `Deploy Dev` or `Remove Dev` GitHub Actions to deploy or remove the AWS Lambda Function.

### Modal

1. Add your Modal credentials (`MODAL_TOKEN_ID`, `MODAL_TOKEN_SECRET` and `MODAL_USERNAME`) to the repository secrets. You can do this by navigating to [https://github.com/your-username/open-text-embeddings/settings/secrets/actions]().

2. Manually trigger the `Deploy Modal` GitHub Actions to deploy the Modal web endpoints.


## 🧪 Testing the Embeddings Endpoint

To test the `embeddings` endpoint, the repository includes an [embeddings.ipynb](https://github.com/limcheekin/open-text-embeddings/blob/main/embeddings.ipynb) notebook with a LangChain-compatible `OpenAIEmbeddings` class.

To get started:

1. Install the dependencies by executing the following command:

   ```bash
   pip install --no-cache-dir open-text-embeddings openai
   ```

2. Execute the cells in the notebook to test the embeddings endpoint.

## 🧑‍💼 Contributing

Contributions are welcome! Please check out the issues on the repository, and feel free to open a pull request.
For more information, please see the [contributing guidelines](CONTRIBUTING.md).

<a href="https://github.com/limcheekin/open-text-embeddings/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=limcheekin/open-text-embeddings" />
</a>

Thank you very much for the following contributions:

- [Vokturz](https://github.com/Vokturz) contributed [#2](https://github.com/limcheekin/open-text-embeddings/pull/2): support for CPU/GPU choice and initialization before starting the app.
- [jayxuz](https://github.com/jayxuz) contributed [#5](https://github.com/limcheekin/open-text-embeddings/pull/5): improved OpenAI API compatibility, better support for previous versions of Python (start from v3.7), better defaults and bug fixes.

## 📔 License

This project is licensed under the terms of the MIT license.

## 🗒️ Citation

If you utilize this repository, please consider citing it with:

```
@misc{open-text-embeddings,
  author = {Lim Chee Kin},
  title = {open-text-embeddings: Open Source Text Embedding Models with OpenAI API-Compatible Endpoint},
  year = {2023},
  publisher = {GitHub},
  journal = {GitHub repository},
  howpublished = {\url{https://github.com/limcheekin/open-text-embeddings}},
}
```
