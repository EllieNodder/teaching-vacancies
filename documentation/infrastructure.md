# Infrastructure diagrams
## [Outdated] Diagrams are not visible anymore. Need to regenerate them.

## CI/CD deployment pipeline

On Pull Request to `main` branch, GitHub Actions `deploy.yml` workflow launches:

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggVERcblxuRGV2ZWxvcGVyKChEZXZlbG9wZXIpKVxuXG5EZXZlbG9wZXIgLS0-IHxQUiB0byBtYXN0ZXIgYnJhbmNoIG9uIGh0dHBzOi8vZ2l0aHViLmNvbS9ERkUtRGlnaXRhbC90ZWFjaGluZy12YWNhbmNpZXN8R2l0SHViTWFzdGVyKEdpdEh1YiBtYXN0ZXIgYnJhbmNoKVxuR2l0SHViTWFzdGVyIC0tPiB8U3RhcnQgR2l0SHViIEFjdGlvbnMgV29ya2Zsb3cgYW5kIFVidW50dSBWaXJ0dWFsIEVudmlyb25tZW50fCBHaXRIdWJWaXJ0dWFsRW52KEdpdEh1YiB2aXJ0dWFsIGVudmlyb25tZW50KVxuR2l0SHViVmlydHVhbEVudiAtLT4gfERlY29kZSBBV1Mgc2VjcmV0czxiciAvPkNoZWNrIGZvciB3ZWxsLWZvcm1lZCBZQU1MfCBBV1NTU01QYXJhbWV0ZXJTdG9yZVtBV1MgU1NNIFBhcmFtZXRlciBTdG9yZV1cbkdpdEh1YlZpcnR1YWxFbnYgLS0-IHxJbml0aWFsaXNlIFRlcnJhZm9ybSB8R2l0SHViVmlydHVhbEVudlBsdXNUZXJyYWZvcm0oVGVycmFmb3JtIENMSSBvbiBHaXRIdWIgdmlydHVhbCBlbnZpcm9ubWVudClcbkdpdEh1YlZpcnR1YWxFbnYgLS0-IHxEZWNvZGUgR2l0SHViIFNlY3JldHN8R2l0SHViU2VjcmV0cyhHaXRIdWIgU2VjcmV0cylcbkdpdEh1YlZpcnR1YWxFbnYgLS0-IHxCdWlsZCBEb2NrZXIgaW1hZ2U8YnIgLz5QdXNoIHRvIERvY2tlckh1YnwgRG9ja2VySHViXG5HaXRIdWJWaXJ0dWFsRW52UGx1c1RlcnJhZm9ybSAtLT4gfERlY29kZSBBV1Mgc2VjcmV0czxiciAvPkNyZWF0ZSBlbnYgdmFyc3wgQVdTU1NNUGFyYW1ldGVyU3RvcmVbQVdTIFNTTSBQYXJhbWV0ZXIgU3RvcmVdXG5HaXRIdWJWaXJ0dWFsRW52UGx1c1RlcnJhZm9ybSAtLT4gfENyZWF0ZS9VcGRhdGV8IEFXU0Nsb3VkZnJvbnRbQVdTIENsb3VkZnJvbnQgRGlzdHJpYnV0aW9uXVxuR2l0SHViVmlydHVhbEVudlBsdXNUZXJyYWZvcm0gLS0-IHxDcmVhdGUvVXBkYXRlfCBTdGF0dXNjYWtle1N0YXR1c2Nha2UgcnVsZX1cbkdpdEh1YlZpcnR1YWxFbnZQbHVzVGVycmFmb3JtIC0tPiB8Q3JlYXRlL1VwZGF0ZXwgR292VUtQYWFTU2VydmljZXMoLUdvdi5VSyBQYWFTIHNlcnZpY2VzIDxiciAvPlBvc3RncmVTUUw8YnIgLz5SZWRpczxiciAvPlBhcGVydHJhaWwtKVxuR2l0SHViVmlydHVhbEVudlBsdXNUZXJyYWZvcm0gLS0-IHxDcmVhdGUvVXBkYXRlfCBHb3ZVS1BhYVNBcHBzKC1Hb3YuVUsgUGFhUyBhcHBzIDxiciAvPmFuZCB3ZWIgcm91dGUtKVxuRG9ja2VySHViIC0tPiB8UHVsbCBEb2NrZXIgdGFnZ2VkIGltYWdlfCBHb3ZVS1BhYVNBcHBzIiwibWVybWFpZCI6e30sInVwZGF0ZUVkaXRvciI6ZmFsc2V9)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggVERcblxuRGV2ZWxvcGVyKChEZXZlbG9wZXIpKVxuXG5EZXZlbG9wZXIgLS0-IHxQUiB0byBtYXN0ZXIgYnJhbmNoIG9uIGh0dHBzOi8vZ2l0aHViLmNvbS9ERkUtRGlnaXRhbC90ZWFjaGluZy12YWNhbmNpZXN8R2l0SHViTWFzdGVyKEdpdEh1YiBtYXN0ZXIgYnJhbmNoKVxuR2l0SHViTWFzdGVyIC0tPiB8U3RhcnQgR2l0SHViIEFjdGlvbnMgV29ya2Zsb3cgYW5kIFVidW50dSBWaXJ0dWFsIEVudmlyb25tZW50fCBHaXRIdWJWaXJ0dWFsRW52KEdpdEh1YiB2aXJ0dWFsIGVudmlyb25tZW50KVxuR2l0SHViVmlydHVhbEVudiAtLT4gfERlY29kZSBBV1Mgc2VjcmV0czxiciAvPkNoZWNrIGZvciB3ZWxsLWZvcm1lZCBZQU1MfCBBV1NTU01QYXJhbWV0ZXJTdG9yZVtBV1MgU1NNIFBhcmFtZXRlciBTdG9yZV1cbkdpdEh1YlZpcnR1YWxFbnYgLS0-IHxJbml0aWFsaXNlIFRlcnJhZm9ybSB8R2l0SHViVmlydHVhbEVudlBsdXNUZXJyYWZvcm0oVGVycmFmb3JtIENMSSBvbiBHaXRIdWIgdmlydHVhbCBlbnZpcm9ubWVudClcbkdpdEh1YlZpcnR1YWxFbnYgLS0-IHxEZWNvZGUgR2l0SHViIFNlY3JldHN8R2l0SHViU2VjcmV0cyhHaXRIdWIgU2VjcmV0cylcbkdpdEh1YlZpcnR1YWxFbnYgLS0-IHxCdWlsZCBEb2NrZXIgaW1hZ2U8YnIgLz5QdXNoIHRvIERvY2tlckh1YnwgRG9ja2VySHViXG5HaXRIdWJWaXJ0dWFsRW52UGx1c1RlcnJhZm9ybSAtLT4gfERlY29kZSBBV1Mgc2VjcmV0czxiciAvPkNyZWF0ZSBlbnYgdmFyc3wgQVdTU1NNUGFyYW1ldGVyU3RvcmVbQVdTIFNTTSBQYXJhbWV0ZXIgU3RvcmVdXG5HaXRIdWJWaXJ0dWFsRW52UGx1c1RlcnJhZm9ybSAtLT4gfENyZWF0ZS9VcGRhdGV8IEFXU0Nsb3VkZnJvbnRbQVdTIENsb3VkZnJvbnQgRGlzdHJpYnV0aW9uXVxuR2l0SHViVmlydHVhbEVudlBsdXNUZXJyYWZvcm0gLS0-IHxDcmVhdGUvVXBkYXRlfCBTdGF0dXNjYWtle1N0YXR1c2Nha2UgcnVsZX1cbkdpdEh1YlZpcnR1YWxFbnZQbHVzVGVycmFmb3JtIC0tPiB8Q3JlYXRlL1VwZGF0ZXwgR292VUtQYWFTU2VydmljZXMoLUdvdi5VSyBQYWFTIHNlcnZpY2VzIDxiciAvPlBvc3RncmVTUUw8YnIgLz5SZWRpczxiciAvPlBhcGVydHJhaWwtKVxuR2l0SHViVmlydHVhbEVudlBsdXNUZXJyYWZvcm0gLS0-IHxDcmVhdGUvVXBkYXRlfCBHb3ZVS1BhYVNBcHBzKC1Hb3YuVUsgUGFhUyBhcHBzIDxiciAvPmFuZCB3ZWIgcm91dGUtKVxuRG9ja2VySHViIC0tPiB8UHVsbCBEb2NrZXIgdGFnZ2VkIGltYWdlfCBHb3ZVS1BhYVNBcHBzIiwibWVybWFpZCI6e30sInVwZGF0ZUVkaXRvciI6ZmFsc2V9)

## Web visit

[![](https://mermaid.ink/img/eyJjb2RlIjoiZ3JhcGggVERcblxuRW5kVXNlcigoRW5kIHVzZXIpKVxuXG5FbmRVc2VyIC0tPiB8QnJvd3NlIHRvIGh0dHBzOi8vdGVhY2hpbmctdmFjYW5jaWVzLnNlcnZpY2UuZ292LnVrfFJvdXRlNTNbUm91dGU1M11cblJvdXRlNTMgLS0-IHxBbGlhcyBBIHJlY29yZHwgQ2xvdWRmcm9udFxuQ2xvdWRmcm9udCAtLT4gfFJlY29yZCBTdGFuZGFyZCBMb2dzfFMzY2xvdWRmcm9udGxvZ3NbUzMgYnVja2V0OiBgY2xvdWRmcm9udGxvZ3NgXVxuQ2xvdWRmcm9udCAtLT4gfENhY2hlIHN0YXRpYyBhc3NldHN8U2l0ZU9ubGluZXtQYWFTIHNpdGUgb25saW5lP31cbkNsb3VkZnJvbnQgLS0-IEFDTUNlcnRpZmljYXRlW0FXUy1pc3N1ZWQgY2VydGlmaWNhdGVdXG5TaXRlT25saW5lIC0tPnxOb3wgT2ZmbGluZVVSSVtTZXJ2ZSBPZmZsaW5lIHBhZ2VzXVxuT2ZmbGluZVVSSSAtLT58aHR0cHM6Ly90dnMtb2ZmbGluZS5zMy5hbWF6b25hd3MuY29tL3NjaG9vbC1qb2JzLW9mZmxpbmUvaW5kZXguaHRtbHxTM29mZmxpbmVbUzMgYnVja2V0IGB0dnMtb2ZmbGluZWBdXG5TaXRlT25saW5lIC0tPnxZZXN8IFBhYVNbQ0ROIHRvIEdvdi5VSyBQYWFTXVxuUGFhUyAtLT58aHR0cHM6Ly90ZWFjaGluZy12YWNhbmNpZXMtcHJvZHVjdGlvbi5sb25kb24uY2xvdWRhcHBzLmRpZ2l0YWx8R292LlVLUGFhUygtR292LlVLIFBhYVMtKSIsIm1lcm1haWQiOnt9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)](https://mermaid-js.github.io/mermaid-live-editor/#/edit/eyJjb2RlIjoiZ3JhcGggVERcblxuRW5kVXNlcigoRW5kIHVzZXIpKVxuXG5FbmRVc2VyIC0tPiB8QnJvd3NlIHRvIGh0dHBzOi8vdGVhY2hpbmctdmFjYW5jaWVzLnNlcnZpY2UuZ292LnVrfFJvdXRlNTNbUm91dGU1M11cblJvdXRlNTMgLS0-IHxBbGlhcyBBIHJlY29yZHwgQ2xvdWRmcm9udFxuQ2xvdWRmcm9udCAtLT4gfFJlY29yZCBTdGFuZGFyZCBMb2dzfFMzY2xvdWRmcm9udGxvZ3NbUzMgYnVja2V0OiBgY2xvdWRmcm9udGxvZ3NgXVxuQ2xvdWRmcm9udCAtLT4gfENhY2hlIHN0YXRpYyBhc3NldHN8U2l0ZU9ubGluZXtQYWFTIHNpdGUgb25saW5lP31cbkNsb3VkZnJvbnQgLS0-IEFDTUNlcnRpZmljYXRlW0FXUy1pc3N1ZWQgY2VydGlmaWNhdGVdXG5TaXRlT25saW5lIC0tPnxOb3wgT2ZmbGluZVVSSVtTZXJ2ZSBPZmZsaW5lIHBhZ2VzXVxuT2ZmbGluZVVSSSAtLT58aHR0cHM6Ly90dnMtb2ZmbGluZS5zMy5hbWF6b25hd3MuY29tL3NjaG9vbC1qb2JzLW9mZmxpbmUvaW5kZXguaHRtbHxTM29mZmxpbmVbUzMgYnVja2V0IGB0dnMtb2ZmbGluZWBdXG5TaXRlT25saW5lIC0tPnxZZXN8IFBhYVNbQ0ROIHRvIEdvdi5VSyBQYWFTXVxuUGFhUyAtLT58aHR0cHM6Ly90ZWFjaGluZy12YWNhbmNpZXMtcHJvZHVjdGlvbi5sb25kb24uY2xvdWRhcHBzLmRpZ2l0YWx8R292LlVLUGFhUygtR292LlVLIFBhYVMtKSIsIm1lcm1haWQiOnt9LCJ1cGRhdGVFZGl0b3IiOmZhbHNlfQ)

## Key

- Circle - End user
- Diamond - Third parties other than AWS and GitHub
- Ellipse - Gov.UK PaaS
- Rectangle - AWS
- Rounded rectangle - GitHub

## Mermaid.js

Diagram generated with [Mermaid.js](https://mermaid-js.github.io/mermaid/#/) and [Mermaid.ink](https://mermaid.ink/)

Preview with [Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)

From [diagrams.net](https://www.diagrams.net/blog/mermaid-diagrams)
```
((circle))
{diamond}
(-ellipse-)
[rectangle]
(rounded rectangle)
```
