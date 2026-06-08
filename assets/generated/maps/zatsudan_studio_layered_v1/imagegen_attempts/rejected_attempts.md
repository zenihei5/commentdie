# Rejected Image Generation Attempts

This folder records image-generation attempts for the zatsudan studio layered map.

## Attempt 1

Target: `zatsudan_studio_floor_2200x1500.png` replacement candidate.

Result: Rejected.

Reason: The generated image drifted into a text-heavy educational/medical poster style instead of a top-down game map. It included readable/inferred text-like content and could not be used as a runtime floor layer.

## Attempt 2

Target: `zatsudan_studio_floor_2200x1500.png` replacement candidate.

Result: Rejected.

Reason: The stricter prompt still drifted into infographic/poster content. It did not satisfy the map contract: no text, no UI, no actors, no infographic layout, and foundation-only floor art.

## Attempt 3

Target: `zatsudan_studio_floor_2200x1500.png` replacement candidate.

Result: Rejected.

Reason: The simplified "empty top-down game floor layer" prompt still produced a text-heavy infographic/poster image. It included readable English text and photographic subject panels, so it cannot be used or postprocessed into the game map.

## Attempt 4

Target: `zatsudan_studio_floor_2200x1500.png` replacement candidate.

Result: Rejected.

Reason: Even after removing livestream/comment/studio terminology and prompting only for an empty floor texture, the generation again produced a medical/educational infographic with large readable text. This confirms that the current image-generation route is not reliable for this map floor pass.

## Attempt 5

Target: `zatsudan_studio_floor_2200x1500.png` replacement candidate.

Result: Rejected.

Reason: A very short English prompt still produced a physics formula reference sheet instead of a game floor. The output was entirely text/diagram based.

## Attempt 6

Target: `zatsudan_studio_floor_2200x1500.png` replacement candidate.

Result: Rejected.

Reason: A short Japanese prompt asking only for a no-text 2D game floor produced a solar-system educational poster. The image-generation route remains unusable for this floor asset.

## Notes

Rejected generated images should not be copied into the runtime asset folder.
The current procedural layered map remains the active fallback until a generated floor layer passes visual and contract checks.
