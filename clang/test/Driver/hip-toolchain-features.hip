// REQUIRES: clang-driver
// REQUIRES: x86-registered-target
// REQUIRES: amdgpu-registered-target

// RUN: %clang -### -target x86_64-linux-gnu -fgpu-rdc -nogpulib \
// RUN:   --cuda-gpu-arch=gfx906:xnack+ --cuda-gpu-arch=gfx900:xnack+ %s \
// RUN:   2>&1 | FileCheck %s -check-prefix=XNACK
// RUN: %clang -### -target x86_64-linux-gnu -fgpu-rdc -nogpulib \
// RUN:   --cuda-gpu-arch=gfx906:xnack- --cuda-gpu-arch=gfx900:xnack- %s \
// RUN:   2>&1 | FileCheck %s -check-prefix=NOXNACK

// XNACK: {{.*}}clang{{.*}}"-target-feature" "+xnack"
// NOXNACK: {{.*}}clang{{.*}}"-target-feature" "-xnack"

// RUN: %clang -### -target x86_64-linux-gnu -fgpu-rdc -nogpulib \
// RUN:   --cuda-gpu-arch=gfx908:sram-ecc+ %s \
// RUN:   2>&1 | FileCheck %s -check-prefix=SRAM
// RUN: %clang -### -target x86_64-linux-gnu -fgpu-rdc -nogpulib \
// RUN:   --cuda-gpu-arch=gfx908:sram-ecc- %s \
// RUN:   2>&1 | FileCheck %s -check-prefix=NOSRAM

// SRAM: {{.*}}clang{{.*}}"-target-feature" "+sram-ecc"
// NOSRAM: {{.*}}clang{{.*}}"-target-feature" "-sram-ecc"

// RUN: %clang -### -target x86_64-linux-gnu -fgpu-rdc -nogpulib \
// RUN:   --cuda-gpu-arch=gfx908:xnack+:sram-ecc+ %s \
// RUN:   2>&1 | FileCheck %s -check-prefix=ALL3
// RUN: %clang -### -target x86_64-linux-gnu -fgpu-rdc -nogpulib \
// RUN:   --cuda-gpu-arch=gfx908:xnack-:sram-ecc- %s \
// RUN:   2>&1 | FileCheck %s -check-prefix=NOALL3

// ALL3: {{.*}}clang{{.*}}"-target-feature" "+sram-ecc" "-target-feature" "+xnack"
// NOALL3: {{.*}}clang{{.*}}"-target-feature" "-sram-ecc" "-target-feature" "-xnack"

// RUN: %clang -### -target x86_64-linux-gnu -fgpu-rdc -nogpulib \
// RUN:   --cuda-gpu-arch=gfx1010 %s \
// RUN:   -mcumode -mcumode -mno-cumode -mwavefrontsize64 -mcumode \
// RUN:   -mwavefrontsize64 -mno-wavefrontsize64 2>&1 \
// RUN:   | FileCheck %s -check-prefix=DUP
// DUP: {{.*}}clang{{.*}} "-target-feature" "+cumode"
// DUP-NOT: "-target-feature" "{{.*}}wavefrontsize16"
// DUP-NOT: "-target-feature" "{{.*}}wavefrontsize32"
// DUP-NOT: "-target-feature" "{{.*}}wavefrontsize64"
// DUP: {{.*}}lld{{.*}} "-plugin-opt=-mattr=+cumode"

// RUN: %clang -### -target x86_64-linux-gnu -fgpu-rdc -nogpulib \
// RUN:   --cuda-gpu-arch=gfx1010 %s \
// RUN:   -mno-wavefrontsize64 -mwavefrontsize64 2>&1 \
// RUN:   | FileCheck %s -check-prefix=WAVE64
// WAVE64: {{.*}}clang{{.*}} "-target-feature" "+wavefrontsize64"
// WAVE64-NOT: "-target-feature" "{{.*}}wavefrontsize16"
// WAVE64-NOT: "-target-feature" "{{.*}}wavefrontsize32"
// WAVE64: {{.*}}lld{{.*}} "-plugin-opt=-mattr=+wavefrontsize64"
