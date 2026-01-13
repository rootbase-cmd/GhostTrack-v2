async function gtLoadSensors() {
    const res = await fetch("sensors.json");
    window.GT_SENSORS = await res.json();
}

async function gtCheckModuleStatus(moduleName, baseUrl) {
    const mod = window.GT_SENSORS.modules[moduleName];
    if (!mod) return null;

    const sensor = mod.sensors[0];
    if (!sensor) return null;

    try {
        const res = await fetch(baseUrl + sensor.endpoint);
        if (!res.ok) return { status: "offline" };
        return { status: "online", data: await res.json() };
    } catch {
        return { status: "offline" };
    }
}
