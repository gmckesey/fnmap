# Upgrading the fnmap Snap in the Snap Store

This step-by-step guide walks you through building, testing, uploading, and releasing an updated version of **fnmap** to the Snap Store.

---

## 1. Current State & Release Context

* **Store Release (Current):** `1.3.4.1` (channel: `latest/stable`, `strict` confinement)
* **New Target Version:** `1.4.0` (channel: `latest/stable`, `classic` confinement)
* **Key Change:** fnmap now uses `classic` confinement to allow running privileged Nmap scans directly against host interfaces and raw sockets without sandbox restrictions.

> [!IMPORTANT]
> **Classic Confinement Notice:** Because fnmap was previously published under `strict` confinement, transitioning to `classic` confinement may trigger a manual review by the Snapcraft Store review team when uploading. If prompted, classic confinement must be approved for the snap name on [forum.snapcraft.io](https://forum.snapcraft.io/c/store-requests/).

---

## 2. Prerequisites & Authentication

### 2.1 Verify Snapcraft CLI
Ensure `snapcraft` is installed and accessible:

```bash
snapcraft --version
```

### 2.2 Log in to Ubuntu One / Snapcraft
Log in to the publisher account owning the `fnmap` store registration:

```bash
snapcraft login
```

Follow the prompts to enter your Ubuntu One credentials and 2FA token.

Verify that your session is active and displays your publisher identity:

```bash
snapcraft whoami
```

---

## 3. Verify Version Synchronization

Ensure version `1.4.0` is consistently configured across project metadata:

1. **[snapcraft.yaml](file:///home/gmckesey/Development/Local/StudioProjects/fnmap/snapcraft.yaml)**:
   ```yaml
   version: '1.4.0'
   confinement: classic
   ```
2. **[pubspec.yaml](file:///home/gmckesey/Development/Local/StudioProjects/fnmap/pubspec.yaml)**:
   ```yaml
   version: 1.4.0+1
   ```
3. **[lib/constants.dart](file:///home/gmckesey/Development/Local/StudioProjects/fnmap/lib/constants.dart)**:
   ```dart
   const String kAppVersion = '1.4.0';
   ```

---

## 4. Build the Production Snap Package

Use the repository's build automation script [build-snap.sh](file:///home/gmckesey/Development/Local/StudioProjects/fnmap/build-snap.sh) to create an isolated production package.

### 4.1 Run the Production Build
From the repository root:

```bash
./build-snap.sh -p
```

*This runs `flutter clean`, clears temporary staging directories, and invokes `snapcraft pack` inside an isolated container (LXD/Multipass).*

Alternatively, you can run `snapcraft pack` directly:

```bash
snapcraft pack
```

Once completed, a package named `fnmap_1.4.0_amd64.snap` will be located in the project root directory.

---

## 5. Local Smoke-Testing

Before pushing to the store, verify the newly generated `.snap` locally:

### 5.1 Install Locally with Classic Permissions
Install the package locally (the `--dangerous` flag permits installing unasserted local files):

```bash
sudo snap install --classic --dangerous fnmap_1.4.0_amd64.snap
```

### 5.2 Validate the Installation
1. Launch fnmap:
   ```bash
   fnmap
   ```
2. In the UI, open **Help -> About** and verify that the version reports `1.4.0`.
3. Perform a quick privileged scan (e.g. `nmap -sS localhost`) to ensure classic confinement operates as expected.

### 5.3 Remove Local Test Build
Remove the local test snap prior to testing store channels:

```bash
sudo snap remove fnmap
```

---

## 6. Upload and Release to the Snap Store

It is best practice to release to the `candidate` channel first, test the store build, and then promote it to `stable`.

### Option A: Recommended Staged Release (Candidate -> Stable)

1. **Upload to Candidate Channel:**
   ```bash
   snapcraft upload --release=candidate fnmap_1.4.0_amd64.snap
   ```

   *Note the revision number returned in the terminal output (e.g. `Revision 5`).*

2. **Test the Store Candidate Release:**
   ```bash
   sudo snap install fnmap --channel=candidate --classic
   fnmap
   ```

3. **Promote Revision to Stable:**
   ```bash
   snapcraft release fnmap <REVISION_NUMBER> stable
   ```
   *(Replace `<REVISION_NUMBER>` with the integer revision from step 1, e.g. `snapcraft release fnmap 5 stable`)*

---

### Option B: Direct Release to Stable

If you want to release directly to the public stable channel:

```bash
snapcraft upload --release=stable fnmap_1.4.0_amd64.snap
```

---

## 7. Handling Classic Confinement Manual Review

Because `1.3.4.1` was confined strictly and `1.4.0` requests `classic`:

* If the upload output states **"classic confinement requires manual review"** or fails automated review:
  1. Visit the [Snapcraft Dashboard](https://snapcraft.io/fnmap/releases).
  2. Check the status of your uploaded revision under **Releases**.
  3. If required, submit a request on the [Snapcraft Forum under "store-requests"](https://forum.snapcraft.io/c/store-requests/) explaining that `fnmap` is a network utility frontend requiring raw socket access, privileged interface scanning, and root execution of system `nmap`.
  4. Once approved by Canonical reviewers, the revision can be released to `stable`.

---

## 8. Post-Release Verification

### 8.1 Check Store Status
Check current release status across channels:

```bash
snapcraft status fnmap
```

Or query the public store metadata:

```bash
snap info fnmap
```
*(Verify that `latest/stable` reports `1.4.0`)*

### 8.2 Verify Public Install / Refresh
Test the public stable release on your system:

```bash
sudo snap install fnmap --classic
```
Or if already installed:
```bash
sudo snap refresh fnmap --classic
```

---

## 9. Cleanup Build Environment

After building snaps, Snapcraft may leave parts and override certain Flutter build files. Use [clean-snap.sh](file:///home/gmckesey/Development/Local/StudioProjects/fnmap/clean-snap.sh) to reset your Flutter development workspace:

```bash
./clean-snap.sh
```

This cleans temporary build directories (`parts/`, `stage/`, `prime/`, `.snapcraft/`), regenerates the Flutter platform templates, and runs `flutter pub get`.
