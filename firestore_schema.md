# Firestore Schema

## Collections Overview
- users
- businesses
- services
- providers
- queues
- tickets

---

## users
{
  userId: string,
  name: string,
  role: "user" | "admin" | "provider",
  phone: string,
  createdAt: timestamp
}

---

## businesses
{
  businessId: string,
  name: string,
  type: string,
  location: string,
  adminId: string
}

---

## services
{
  serviceId: string,
  businessId: string,
  name: string,
  serviceTime: number
}

---

## providers
{
  providerId: string,
  userId: string,
  serviceId: string,
  isAvailable: boolean
}

---

## queues
{
  queueId: string,
  serviceId: string,
  currentNumber: number,
  status: "open" | "closed"
}

---

## tickets
{
  ticketId: string,
  number: number,
  serviceId: string,
  businessId: string,
  userId: string,

  status: "waiting" | "called" | "in_service" | "done" | "skipped" | "cancelled",

  assignedProviderId: string | null,

  createdAt: timestamp,
  calledAt: timestamp,
  startedAt: timestamp,
  finishedAt: timestamp
}