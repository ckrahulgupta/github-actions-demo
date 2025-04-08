((portalext) => {
    let root = document.documentElement;

    // Function to convert hex color to RGB
    portalext.hexToRgb = (hex) => {
        hex = hex.replace("#", "");
        const bigint = parseInt(hex, 16);
        const r = (bigint >> 16) & 255;
        const g = (bigint >> 8) & 255;
        const b = bigint & 255;
        return `${r}, ${g}, ${b}`;
    };

    // Function to set theme colors
    portalext.setThemeColors = (
        primaryColor,
        secondaryColor,
        tertiaryColor
    ) => {
        try {
            root.style.setProperty("--primary-color", primaryColor || "#61734b");
            root.style.setProperty("--primary-color-rgb", portalext.hexToRgb(primaryColor || "#61734b"));
            root.style.setProperty("--secondary-color", secondaryColor || "#ac754b");
            root.style.setProperty("--secondary-color-rgb", portalext.hexToRgb(secondaryColor || "#ac754b"));
            root.style.setProperty("--tertiary-color", tertiaryColor || "#efceb8");
            root.style.setProperty("--tertiary-color-rgb", portalext.hexToRgb(tertiaryColor || "#efceb8"));
            portalext.showContent(); // Show content once the theme colors are set
        } catch (error) {
            console.error(error);
        }
    };

    // Function to set the portal logo
    portalext.setPortalLogo = (logo) => {
        try {
            if (logo) {
                root.style.setProperty("--portal-logo", `url("/resource/${logo}")`);
            } else {
                root.style.setProperty("--portal-logo", `url("/resource/dealerPortalLogo")`);
            }
        } catch (error) {
            console.error(error);
        }
    };

    // Function to set the navigation banner
    portalext.setNavBanner = (banner) => {
        try {
            if (banner) {
                root.style.setProperty("--nav-banner", `url("/resource/${banner}")`);
            } else {
                root.style.setProperty("--nav-banner", `url("/resource/dealerPortalDashboardBackgroundImage")`);
            }
        } catch (error) {
            console.error(error);
        }
    };

    // Function to check if the current user is builder admin
    portalext.isBuilderAdmin = (builder) => {
        if (builder) {
            portalext.showContent();
        }
    };

    // Function to check if content is ready to display
    portalext.showContent = () => {
        const loader = document.getElementById("loader");
        loader.style.display = "none"; // Hide loader
    };

    // Create and insert the loader element
    const createLoaderElement = () => {
        const loader = document.createElement("div");
        loader.id = "loader";
        const spinner = document.createElement("div");
        spinner.className = "spinner";
        loader.appendChild(spinner);
        document.body.appendChild(loader);
    };

    // Initialization function to set up the loader
    const init = () => {
        createLoaderElement();
    };

    // Initialize the loader setup
    init();
})((window.portalext = window.portalext || {}));
