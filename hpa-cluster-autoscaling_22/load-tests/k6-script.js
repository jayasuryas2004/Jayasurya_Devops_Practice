import http from 'k6/http';
export const options = { vus: 150, duration: '5m' };
export default function () { http.get('http://hpa-demo-svc.autoscale-demo.svc.cluster.local/'); }
