export default function DistrictOfficerDashboard() {
  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-2">
        <h1 className="text-3xl font-bold tracking-tight">District Officer Dashboard</h1>
        <p className="text-zinc-400">Macro-level monitoring and pest alert management.</p>
      </div>
      
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-purple-500">District Farmers</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-purple-500">Field Workers</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-purple-500">Active Pest Alerts</h3>
          <p className="text-2xl font-bold">0</p>
        </div>
        <div className="rounded-xl border border-zinc-800 bg-zinc-900/50 p-6">
          <h3 className="font-semibold text-purple-500">Crop Distribution</h3>
          <p className="text-2xl font-bold">See Chart</p>
        </div>
      </div>
    </div>
  );
}
