import { MeiliSearch } from 'meilisearch';
import { config } from '../config';

let meilisearchClient: MeiliSearch | null = null;

export function getMeilisearchClient(): MeiliSearch {
  if (!meilisearchClient) {
    meilisearchClient = new MeiliSearch({
      host: config.meilisearch.host,
      apiKey: config.meilisearch.masterKey
    });
  }
  
  return meilisearchClient;
}
















