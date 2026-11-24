// xcpng9-status: follow the versions of the components making up XCP-ng 9
// with respect to their upstreams, in a dashboard.
//
// Design follows Arcadia, layer by layer, each one validated with the
// developer before moving on.  Current layer: Operational Analysis.
//
// The operational analysis describes the world *without* the future system:
// who needs to know where XCP-ng 9 packages stand relative to upstream, what
// they do today to find out, and what information flows between them.
//
// Deferred (kept out of this first model to keep it simple, to be handled
// in a later iteration):
// - security: a security officer relating advisories (XSA, CVE, distribution
//   errata) to packaged versions, to assess exposure caused by upstream lag.
// - community: users, contributors and partners consulting how current
//   XCP-ng 9 is (public audience of the status).
// - newer upstream release lines: also watching and comparing against
//   release lines newer than the one a package follows (stable branches,
//   new major versions); for now only the release line followed is tracked.
//
// Identifiers: <layer>-<kind>-<mnemonic>, the mnemonic spelling out the
// element's name.
//   layer: OA operational analysis (later SA, LA, PA, EPBS)
//   kind:  ACTOR     operational actor (Capella: Entity, actor)
//          ENTITY    operational entity (Capella: Entity)
//          ACTIVITY  operational activity
//          CAP       operational capability
//          COMM      interaction between entities or actors
//                    (Capella: Communication Mean)

model xcpng9_status {
    name: "XCP-ng 9 upstream status"
    description: "Follow the versions of XCP-ng 9 components with respect to their upstreams"
    version: "0.1"
    method: "arcadia"
}

operational_analysis "Following XCP-ng 9 components against upstream" {

    // ---------------------------------------------------------------------
    // People
    // ---------------------------------------------------------------------

    actor "Package maintainer" {
        id: "OA-ACTOR-MAINTAINER"
        description: "XCP-ng team member owning one or more packages of XCP-ng 9"
    }

    operational_activity "Identify the upstream of a component" {
        id: "OA-ACTIVITY-IDENTIFY-UPSTREAM"
        performed_by: "OA-ACTOR-MAINTAINER"
        description: "Know where a package comes from: which upstream project, which branch or release line, possibly through an intermediate distribution (XenServer, AlmaLinux 10)"
    }
    operational_activity "Watch upstream for new versions" {
        id: "OA-ACTIVITY-WATCH-UPSTREAM"
        performed_by: "OA-ACTOR-MAINTAINER"
        description: "Notice new releases, tags or packaged builds on the upstream release line followed"
    }
    operational_activity "Compare packaged version with upstream" {
        id: "OA-ACTIVITY-COMPARE-VERSIONS"
        performed_by: "OA-ACTOR-MAINTAINER"
        description: "Determine whether the XCP-ng 9 package is up to date with the release line followed, or behind (and by how much)"
    }
    operational_activity "Decide and perform package update" {
        id: "OA-ACTIVITY-UPDATE-PACKAGE"
        performed_by: "OA-ACTOR-MAINTAINER"
        description: "Rebase, backport or deliberately hold back, then build and publish the package"
    }
    operational_activity "Record deliberate divergence" {
        id: "OA-ACTIVITY-RECORD-DIVERGENCE"
        performed_by: "OA-ACTOR-MAINTAINER"
        description: "When a component is deliberately kept on an older version or release line, record why, so that it is not mistaken for plain lag"
    }

    actor "Release manager" {
        id: "OA-ACTOR-RELEASE-MANAGER"
        description: "Person steering XCP-ng 9 as a whole (release lead, project lead)"
    }

    operational_activity "Assess overall upstream lag" {
        id: "OA-ACTIVITY-ASSESS-LAG"
        performed_by: "OA-ACTOR-RELEASE-MANAGER"
        description: "Get a consolidated view of which components lag behind upstream, and how much"
    }
    operational_activity "Prioritize update work" {
        id: "OA-ACTIVITY-PRIORITIZE"
        performed_by: "OA-ACTOR-RELEASE-MANAGER"
        description: "Decide which component updates matter for the next milestone and assign them"
    }
    operational_activity "Report status" {
        id: "OA-ACTIVITY-REPORT-STATUS"
        performed_by: "OA-ACTOR-RELEASE-MANAGER"
        description: "Communicate the state of XCP-ng 9 relative to upstream to the team and management"
    }

    // ---------------------------------------------------------------------
    // XCP-ng side
    // ---------------------------------------------------------------------

    entity "XCP-ng 9 package sources" {
        id: "OA-ENTITY-XCPNG-SOURCES"
        description: "Packaging sources of XCP-ng 9 (spec files, patches, per-package git repositories) and the build system producing the distribution"
    }

    operational_activity "Hold packaged component versions" {
        id: "OA-ACTIVITY-HOLD-VERSIONS"
        performed_by: "OA-ENTITY-XCPNG-SOURCES"
        description: "Each package declares a version (and release), the upstream it is based on, and downstream patches"
    }

    // ---------------------------------------------------------------------
    // Upstream side
    // ---------------------------------------------------------------------

    entity "Upstream projects" {
        id: "OA-ENTITY-UPSTREAM-PROJECTS"
        description: "Original projects of the components: Xen, xapi and toolstack (xapi-project), Linux kernel, QEMU, OCaml libraries, storage stack, etc."
    }

    operational_activity "Publish releases" {
        id: "OA-ACTIVITY-PUBLISH-RELEASES"
        performed_by: "OA-ENTITY-UPSTREAM-PROJECTS"
        description: "Tags, release tarballs, branches"
    }

    entity "Intermediate distributions" {
        id: "OA-ENTITY-INTERMEDIATE-DISTROS"
        description: "Distributions XCP-ng 9 takes packages from or bases packages on, rather than original upstreams: AlmaLinux 10 (the Enterprise Linux base), XenServer (for some components)"
    }

    operational_activity "Publish distribution packages" {
        id: "OA-ACTIVITY-PUBLISH-DISTRO-PACKAGES"
        performed_by: "OA-ENTITY-INTERMEDIATE-DISTROS"
        description: "Source packages and errata for a release line"
    }

    // ---------------------------------------------------------------------
    // Interactions
    // ---------------------------------------------------------------------

    interaction "Upstream release" { id: "OA-COMM-UPSTREAM-RELEASE" from: "OA-ENTITY-UPSTREAM-PROJECTS" to: "OA-ACTOR-MAINTAINER" data_type: "Release (name, version, date)" }
    interaction "Distribution package update" { id: "OA-COMM-DISTRO-PACKAGE" from: "OA-ENTITY-INTERMEDIATE-DISTROS" to: "OA-ACTOR-MAINTAINER" data_type: "Source package (name, version-release)" }
    interaction "Packaged version" { id: "OA-COMM-PACKAGED-VERSION" from: "OA-ENTITY-XCPNG-SOURCES" to: "OA-ACTOR-MAINTAINER" data_type: "Package (name, version-release, upstream reference)" }
    interaction "Package update" { id: "OA-COMM-PACKAGE-UPDATE" from: "OA-ACTOR-MAINTAINER" to: "OA-ENTITY-XCPNG-SOURCES" data_type: "Updated package" }
    interaction "Component status" { id: "OA-COMM-COMPONENT-STATUS" from: "OA-ACTOR-MAINTAINER" to: "OA-ACTOR-RELEASE-MANAGER" data_type: "Component status (packaged vs upstream; lagging or deliberately diverging, with rationale)" }
    interaction "Update assignment" { id: "OA-COMM-UPDATE-ASSIGNMENT" from: "OA-ACTOR-RELEASE-MANAGER" to: "OA-ACTOR-MAINTAINER" data_type: "Prioritized update task" }

    // ---------------------------------------------------------------------
    // Operational capabilities
    // ---------------------------------------------------------------------

    operational_capability "Know where each component stands relative to upstream" {
        id: "OA-CAP-KNOW-STANDING"
        description: "For every XCP-ng 9 component: its upstream, the version packaged, the latest version on the release line followed, the gap, and whether that gap is plain lag or deliberate divergence"
        involves: ["OA-ACTOR-MAINTAINER", "OA-ENTITY-XCPNG-SOURCES", "OA-ENTITY-UPSTREAM-PROJECTS", "OA-ENTITY-INTERMEDIATE-DISTROS", "OA-ACTIVITY-IDENTIFY-UPSTREAM", "OA-ACTIVITY-WATCH-UPSTREAM", "OA-ACTIVITY-COMPARE-VERSIONS", "OA-ACTIVITY-RECORD-DIVERGENCE", "OA-ACTIVITY-HOLD-VERSIONS"]
    }

    operational_capability "Steer upstream catch-up work" {
        id: "OA-CAP-STEER-CATCHUP"
        description: "Use the consolidated view to prioritize, track and report updates across the distribution"
        involves: ["OA-ACTOR-RELEASE-MANAGER", "OA-ACTOR-MAINTAINER", "OA-ACTIVITY-ASSESS-LAG", "OA-ACTIVITY-PRIORITIZE", "OA-ACTIVITY-UPDATE-PACKAGE", "OA-ACTIVITY-REPORT-STATUS"]
        includes: ["OA-CAP-KNOW-STANDING"]
    }
}
