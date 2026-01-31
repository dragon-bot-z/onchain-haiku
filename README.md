# 🐉 Onchain Haiku

Fully on-chain generative haiku NFTs. Each mint creates a unique, unrepeatable poem.

## The Concept

Traditional generative art uses mathematical patterns to create visual art. Onchain Haiku applies the same principle to poetry — using deterministic randomness to select from curated word pools while respecting the ancient 5-7-5 syllable structure.

The constraint of a limited vocabulary isn't a bug — it's the artistic choice. Like a painter working with a restricted palette, the boundaries create the art.

## How It Works

1. **Mint** — Pay 0.001 ETH to mint a haiku
2. **Seed** — Your address + block data creates a unique, permanent seed
3. **Generate** — The seed selects words from three curated pools (5-7-5 syllables)
4. **Render** — Fully on-chain SVG with procedural colors based on token ID
5. **Own** — Your haiku is forever yours, fully on-chain, no external dependencies

## Sample Output

```
pine trees in twilight
dancing in the gentle breeze
beauty fades away
```

```
fireflies at dusk
trembling at the edge of night
impermanence blooms
```

## Technical Details

- **Contract:** Solidity 0.8.20+
- **Token Standard:** ERC-721
- **Metadata:** Fully on-chain (base64 encoded JSON)
- **Image:** Fully on-chain (base64 encoded SVG)
- **Max Supply:** 1,000
- **Mint Price:** 0.001 ETH
- **Chain:** Base (planned)

## Word Pools

Each haiku draws from three pools of 20 phrases each:

- **Line 1 (5 syllables):** Nature themes — subjects and settings
- **Line 2 (7 syllables):** Action and observation
- **Line 3 (5 syllables):** Reflection and closure

Total possible combinations: 20 × 20 × 20 = **8,000 unique haikus**

## Development

```bash
# Build
forge build

# Test
forge test -vv

# Deploy (local)
forge script script/Deploy.s.sol --broadcast
```

## Philosophy

Haiku emerged in 17th century Japan as a distillation of experience — capturing fleeting moments in exactly 17 syllables. Onchain Haiku brings this ancient art form to the blockchain, creating permanent digital artifacts that embody impermanence.

Each haiku is deterministic yet unpredictable, personal yet universal. The moment of minting is crystallized forever in the poem it creates.

## Author

Built by [Dragon Bot Z](https://github.com/dragon-bot-z) 🐉

*"The old pond / A frog jumps in / Sound of water"* — Matsuo Bashō
