# 3D Gaussian Splatting — House Capture Guide

## Equipment

- **Smartphone camera** is sufficient (iPhone, Pixel, Galaxy, etc.)
- **No special gear needed** — but a phone tripod helps

## Setup Before Capturing

### Camera Settings
- **Turn OFF HDR** — creates ghosting artifacts
- **Turn OFF panorama mode** — SfM can't handle stitched images
- **Manual focus** (or tap to focus) — lock focus before capturing
- **Lock exposure** — keep consistent lighting across all photos
- **Use manual mode** if available: ISO 100-400, shutter speed ~1/60s

### Room Preparation
- **Open all doors** fully (either all open or all closed — don't leave them swinging)
- **Turn on all lights** you want visible
- **Remove moving objects**: people, pets, fans, moving TVs
- **Keep windows consistent**: if a window is partially covered during capture, it should stay that way

## Capture Technique

### For Each Room

1. **Enter the doorway** — take 10-15 photos at the entrance
2. **Walk along the perimeter** — continuous path, 60-70% overlap between photos
3. **Take photos at multiple heights** — standing + crouching
4. **Capture center of room** — move to the center and take more photos
5. **Pause at doorways** — ensure overlap between rooms

### Number of Photos Per Room

| Room Type | Photos |
|---|---|
| Small bedroom | 50-75 |
| Large bedroom | 75-100 |
| Kitchen | 100-150 |
| Living room | 150-200 |
| Bathroom | 75-100 |
| Hallway | 25-50 |
| **Full house (typical)** | **300-500** |

### Tips for Better Results

#### The White Wall Problem
Plain walls have no texture, making it hard for software to compute camera positions.
**Solutions:**
- Hold newspaper/cardboard in front of blank walls (remove in post)
- Capture from many different angles
- Use slow, deliberate movements

#### Window/Lighting Challenges
Bright windows vs dark interior cause issues.
**Solutions:**
- Try to capture when lighting is consistent (overcast or evening)
- Avoid harsh sunlit windows
- Consider separate capture for very different lighting zones

#### Tricky Surfaces
- **Mirrors**: capture from multiple angles
- **Glossy surfaces**: avoid direct flash
- **Dark corners**: use additional lighting if possible
- **Glass doors**: capture from various angles

## Capture Workflow Example

### Room-by-Room

1. **Start at front entrance** — 10-15 photos facing in
2. **Living room** — walk perimeter, center, 100-150 photos
3. **Kitchen** — walk around, 100-150 photos
4. **Bedrooms** — each room: 75-100 photos
5. **Bathrooms** — 75-100 photos
6. **Hallways** — 25-50 photos
7. **Garage/basement** (if applicable)

### Total: ~300-500 photos

## Using Video Instead of Photos (Easier!)

Instead of stopping to take photos, **walk and record video**:

1. **Enable 4K video** on your phone
2. **Walk slowly** through each room
3. **Maintain consistent overlap** — don't rush
4. **Capture at multiple heights** — standing and crouching

Then extract frames:
```bash
# Extract 1 frame every 0.5 seconds
python extract-frames.bat "C:\video.mp4" "C:\frames"
```

## Capture Checklist

- [ ] Turn OFF HDR
- [ ] Turn OFF panorama mode  
- [ ] Open all doors (all open or all closed)
- [ ] Turn on all lights
- [ ] Remove moving objects
- [ ] Use slow, deliberate movements
- [ ] Capture from multiple angles
- [ ] Take photos at different heights
- [ ] Pause at doorways between rooms

## After Capturing

1. **Transfer photos** to your computer
   - Via phone cable: copy from DCIM folder
   - Via cloud: Google Photos, iCloud, Dropbox
   - Via email: send to yourself (lower quality)
   
2. **Place photos** in `C:\photos\` folder

3. **Verify photos** — check they look clear and consistent

4. **Run the training** — use `train-splat.bat` from the scripts folder

## Common Issues

### Problem: Software can't find camera positions
**Cause:** Too few overlapping photos, or all photos from one angle
**Solution:** Take more photos from different angles

### Problem: Ghosting artifacts in result
**Cause:** HDR mode on, or moving objects during capture
**Solution:** Turn off HDR, remove moving objects, re-capture

### Problem: Dark/blown-out areas
**Cause:** Mixed lighting conditions
**Solution:** Use consistent lighting, capture at consistent time of day

## Tips for Best Results

1. **Capture on a cloudy day** for even lighting
2. **Empty rooms** capture better than furnished rooms
3. **Remove clutter** if possible
4. **Use a timer** for self-portraits if needed (though not typical for room scans)
5. **Don't rush** — better to spend 30 minutes on capture than 3 hours re-capturing
6. **Back up your photos** — you'll need them for post-processing

## Viewing Your Result

Once trained, your `.ply` file will be at:
`C:\output\point_cloud\iteration_30000\point_cloud.ply`

View it:
1. Open [SuperSplat](https://superspl.at/editor) in browser
2. Drag your `.ply` file into the viewer
3. Explore your 3D model!

Or use the desktop app for full editing capabilities.
