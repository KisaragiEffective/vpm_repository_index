# vpm_repository_index
machine readable index for VPM (stands for VRChat Package Manager) repository, licensed under Creative Commons Zero version 1.0

## JSON schema
(TODO: convert this to `application/schema+json` format)

The key words "***MUST***", "***MUST NOT***", "***REQUIRED***", "***SHALL***", "***SHALL NOT***", "***SHOULD***", "***SHOULD NOT***", "***RECOMMENDED***",  "***MAY***", and "***OPTIONAL***" in this document are to be interpreted as described in RFC 2119.

**informative note** does not form this specifiation. It's just side note.

* (root)
  * `metadata`
    * `license`: `SpdxLicenseIdentifier` - the license of this file.
  * `repository`
    * (each array element)
      * `author`: `String` - the maintainer of following repository.
        * example: KisaragiEffective
      * `git_repository`: `Option<Url>` - URL of Git repository. If it exists, there may be chance to view it from git repository. Git repository which associated with this URL ***MUST*** contain one or more valid VPM repository JSON file (regardless of its branch) in the repository (**nb.** GitHub pages does **NOT** satisfy this requirement). If the repository contains multiple valid VPM repository file, then there ***MUST*** be multiple repository entries where each entry corresponds one repository.
        * example: `https://github.com/ExampleOwner/ExampleRepo`
      * `entry`: `Url` - URL of JSON. If `git_repository` does exist, then this URL may point to its HTTP view (**informative note**. One can use GitHub pages, while another can use their hosting service.) Protocol of this value ***SHOULD*** be `https` when possible. Protocol of this value ***MUST NOT*** be `vcc`. Response of the URL ***SHOULD NOT*** be result in "Not Found" nor "Forbidden". Response of the URL ***MUST*** contains valie VPM repository in JSON format. If protocol of this value is either `http` or `https`, the header of `Content-Type` should be `application/json`.
        * example: `https://example.com/vpm.json`.
      * `entry_git`: `Option<Array<_>>` - If it exists, then the following informations can be used to obtain VPM repository. This field ***MUST NOT*** exist if property `git_repository` does not exist. 
        * (each array element) - Every element ***MUST*** point valid VPM repository file by their information. This field ***MAY*** not contain latest information, and therefore there's risk to believe that there are no update according to those entries. **USE AT YOUR OWN PERIL!!**
          * `commit_sha1_long`: `Sha1` - The commit hash of git commit. this hash ***MUST*** be valid SHA-1 value. This hash ***MUST*** be contained in `git_repository`.
          * `path`: `FilePath` - The file path, relative to repository root. The value ***MUST*** starts with forward slash (`/`).
      * `description`: `String` - Free format, but value ***SHOULD*** contain meaningful information that cannot be covered by existent fields.

## License
Creative Commons Zero, version 1.0
